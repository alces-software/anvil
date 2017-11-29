require 'aws-sdk-s3'
require 'open-uri'
require 'yaml'
require 'zip'

module GridwareImport

  GRIDWARE_MAIN_URL = 'https://github.com/alces-software/gridware-packages-main'
  GRIDWARE_VOLATILE_URL = 'https://github.com/alces-software/packager-base'

  GRIDWARE_TAGS = %w(main volatile)

  def self.do_gridware_import
    check_env

    Aws.config.update({
        region: 'eu-west-1'
    })

    import_gridware_from_url(GRIDWARE_MAIN_URL, 'main')
    import_gridware_from_url(GRIDWARE_VOLATILE_URL, 'volatile')
  end

  private

  def self.check_env
    if !ENV['AWS_ACCESS_KEY_ID'] || !ENV['AWS_SECRET_ACCESS_KEY'] || !ENV['AWS_FORGE_ROOT_BUCKET']
      raise 'Need to specify AWS credentials: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_FORGE_ROOT_BUCKET'
    end
  end

  def self.import_gridware_from_url(url, repo_name_for_tag)
    remote_zip = open("#{url}/archive/master.zip")
    alces = User.find_by_name('alces')
    tag = Tag.get_or_create(repo_name_for_tag)

    software_cat = Category.where(name: 'Software').first_or_create

    ::Zip::File.open_buffer(remote_zip) do | zipfile |
      metadata_files = zipfile.glob('**/metadata.yml')
      metadata_files.each do |mdf|
        metadata = YAML.load(mdf.get_input_stream.read)
        path = mdf.name.split('/').drop(1)

        if path[0] == 'pkg'  # Only true in `gridware-packages-main` repository
          path = path.drop(1)
        end

        pkg_name = path[1]
        pkg_version = metadata[:version] || path[-2]

        puts "Processing #{repo_name_for_tag}: alces/#{pkg_name}/#{pkg_version} (Gridware #{path[0..-2].join('/')})"

        package = Package.where(
                             user: alces,
                             name: pkg_name,
                             version: pkg_version
        ).first_or_create

        package.summary = metadata[:summary]
        package.description = metadata[:description]
        package.changelog = metadata[:changelog]
        package.licence = metadata[:license]
        package.website = metadata[:url]
        package.package_url = create_and_upload_package(package, url, path[0..-2].join('/'))
        package.category = Category.where(name: metadata[:group], parent: software_cat).first_or_create

        package.save!  # We need to save so that package gets an ID before we try and tag it

        if (package.tag_names & GRIDWARE_TAGS).empty?  # Don't re-tag packages from main as volatile also
          package.tags << tag
          package.save!
        end

      end
    end
  end

  def self.create_and_upload_package(package, repo_url, package_path)
    s3_object_name = "#{package.user.name}/#{package.name}/#{package.version}.zip"

    tempfile = Tempfile.new('forge-gridware-generator')
    begin
      ::Zip::File.open(tempfile.path, ::Zip::File::CREATE) do |zipfile|
        zipfile.get_output_stream('install.sh') do |f|
          f.write(create_installer_script(repo_url, package_path))
        end
      end

      s3 = Aws::S3::Resource.new
      bucket = s3.bucket(ENV['AWS_FORGE_ROOT_BUCKET'])
      obj = bucket.object(s3_object_name)
      obj.upload_file(tempfile.path)
      obj.acl.put({ acl: 'public-read' })

      return obj.public_url

    ensure
      tempfile.close
      tempfile.unlink
    end
  end

  def self.create_installer_script(repo_url, package_path)
    <<END
#!/bin/bash
# Automatically generated Gridware Forge install script
cw_FORGE_GRIDWARE_SOURCE=#{repo_url}
temp_repo=''
MAGIC_EXIT_CODE=1138

require files
require ruby
files_load_config gridware

ruby_run <<RUBY

require 'yaml'
config = YAML.load_file('${cw_GRIDWARE_root}/etc/gridware.yml')

config[:repo_paths].each do |repo|

  repo_metadata = YAML.load_file("\#{repo}/repo.yml")
  if repo_metadata[:source] == "${cw_FORGE_GRIDWARE_SOURCE}.git"
    exit(${MAGIC_EXIT_CODE})
  end

end

RUBY

if [ $? -ne $MAGIC_EXIT_CODE ] ; then
  temp_repo=$(mktemp -d -t 'forge-gridware-repo-XXXXXXXX')
  ${cw_ROOT}/opt/git/bin/git clone -q "$cw_FORGE_GRIDWARE_SOURCE" "$temp_repo"
fi

cw_FORGE_GRIDWARE_TEMP_REPO="$temp_repo" ${cw_ROOT}/bin/alces gridware install --binary --non-interactive #{package_path}
result=$?

if [ ! -z "$temp_repo" ] ; then
  rm -rf "$temp_repo"
fi

exit $result
END
  end
end

namespace :gridware do

  desc 'Import new Gridware packages, and update existing packages, via metadata from GitHub'
  task :import => :environment do
      GridwareImport.do_gridware_import
  end
end
