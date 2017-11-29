require 'aws-sdk-s3'
require 'open-uri'
require 'yaml'

module CustomizerImport
  class << self

    CUSTOMIZER_SOURCE_BASE_URL = ENV['CUSTOMIZER_SOURCE_BASE_URL'] || 'https://s3-eu-west-1.amazonaws.com/alces-flight-profiles-eu-west-1/2017.1/features'

    def check_env
      if !ENV['AWS_ACCESS_KEY_ID'] || !ENV['AWS_SECRET_ACCESS_KEY'] || !ENV['AWS_FORGE_ROOT_BUCKET']
        raise 'Need to specify AWS credentials: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_FORGE_ROOT_BUCKET'
      end
    end

    def do_customizer_import
      check_env

      Aws.config.update({
        region: 'eu-west-1'
      })

      version = CUSTOMIZER_SOURCE_BASE_URL.split('/')[-2]

      puts "Using S3 base URL #{CUSTOMIZER_SOURCE_BASE_URL} as customizer source (inferred version: #{version})"

      index = YAML.load(open("#{CUSTOMIZER_SOURCE_BASE_URL}/index.yml") { |f| f.read })

      alces = User.find_by_name('alces')

      config_cat = Category.where(name: 'Config').first_or_create
      software_cat = Category.where(name: 'Software').first_or_create
      scheduler_cat = Category.where(name: 'Schedulers', parent: software_cat).first_or_create

      index['profiles'].each do |name, profile|
        if !profile.include?('tags') || !profile['tags'].include?('hidden')
          source_url = "#{CUSTOMIZER_SOURCE_BASE_URL}/#{name}"
          puts "Processing #{source_url}"

          package = Package.where(
              user: alces,
              name: name,
              version: version
          ).first_or_create

          target_object_name = "#{package.user.name}/#{package.name}/#{package.version}.zip"
          tempfile = Tempfile.new('forge-customizer-generator')
          begin
            zip_profile(tempfile, source_url, package)

            package.package_url = upload_profile(tempfile, target_object_name)

          ensure
            tempfile.close
            tempfile.unlink
          end

          package.description = profile['description']
          package.summary = profile['description']
          package.save!

          if profile.include?('tags')

            tags = profile['tags']
            package.tags = tags.map { |tag| Tag.get_or_create(tag) }
            if tags.include?('scheduler')
              package.category = scheduler_cat
            elsif tags.include?('software')
              package.category = software_cat
            elsif tags.include?('config')
              package.category = config_cat
            end
            package.save
          end

        else
          puts "Skipping hidden profile #{name}"
        end
      end
    end

    private

    def list_profile_components(region, bucket_name, prefix)
      s3 = Aws::S3::Resource.new({region: region})
      bucket = s3.bucket(bucket_name)

      bucket.objects({ prefix: prefix })
    end

    def uri_to_components(uri)
      matches = /^https:\/\/s3-([^\/\.]+)\.[^\/]*\/([^\/]*)\/(.*)$/.match(uri)
      matches[1..3]
    end

    def zip_profile(tempfile, source_url, package)
      region, bucket_name, prefix = uri_to_components(source_url)

      begin
        ::Zip::File.open(tempfile.path, ::Zip::File::CREATE) do |zipfile|
          zipfile.get_output_stream('install.sh') do |f|
            f.write(create_installer_script(package))
          end

          list_profile_components(region, bucket_name, prefix).each do |source_file|
            filename = source_file.key[prefix.length + 1..-1]
            zipfile.get_output_stream(filename) do |f|
              f.write(source_file.get.body.read)
            end
          end
        end
      end
    end

    def upload_profile(tempfile, s3_object_name)
      s3 = Aws::S3::Resource.new
      bucket = s3.bucket(ENV['AWS_FORGE_ROOT_BUCKET'])
      obj = bucket.object(s3_object_name)
      obj.upload_file(tempfile.path)
      obj.acl.put({ acl: 'public-read' })

      obj.public_url
    end

      def create_installer_script(package)
        <<END
#!/bin/bash
# Automatically generated customizer Forge install script

require customize
require files
require member
files_load_config cluster-customizer
cw_CLUSTER_CUSTOMIZER_path="${cw_CLUSTER_CUSTOMIZER_path:-${cw_ROOT}/var/lib/customizer}"

_run_member_hooks() {
    local event name ip
    members="$1"
    event="$2"
    shift 3
    name="$1"
    ip="$2"
    if [[ -z "${members}" || ,"$members", == *,"${name}",* ]]; then
       customize_run_hooks "${event}" \
                           "${cw_MEMBER_DIR}"/"${name}" \
                           "${name}" \
                           "${ip}"
    fi
}

repo_name='forge'
profile_name="#{package.user.name}-#{package.name}-#{package.version}"
destination_dir="${cw_CLUSTER_CUSTOMIZER_path}/${repo_name}-${profile_name}"
cp -r . "$destination_dir"

# The following mirrors `customize-repository.functions.sh#customize_repository_apply()`
chmod -R a+x "${destination_dir}/"*.d

echo "Running event hooks for $profile_name"
customize_run_hooks "configure:$repo_name-$profile_name"
customize_run_hooks "start:$repo_name-$profile_name"
customize_run_hooks "node-started:$repo_name-$profile_name"
member_each _run_member_hooks "${members}" "member-join:$repo_name-$profile_name"
END
      end


  end
end

namespace :customizer do

  desc 'Import new and update existing Alces feature profiles into Forge'
  task :import => :environment do
    CustomizerImport.do_customizer_import
  end


end
