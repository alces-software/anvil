require 'open-uri'
require 'yaml'
require 'zip'

GRIDWARE_MAIN_URL = 'https://github.com/alces-software/gridware-packages-main/archive/master.zip'
GRIDWARE_VOLATILE_URL = 'https://github.com/alces-software/packager-base/archive/master.zip'

def do_gridware_import
  import_gridware_from_url(GRIDWARE_MAIN_URL, 'main')
  import_gridware_from_url(GRIDWARE_VOLATILE_URL, 'volatile')
end

def import_gridware_from_url(url, repo_name_for_tag)
  remote_zip = open(url)
  alces = User.find_by_name('alces')
  tag = Tag.get_or_create(repo_name_for_tag)

  ::Zip::File.open_buffer(remote_zip) do | zipfile |
    metadata_files = zipfile.glob('**/metadata.yml')
    metadata_files.each do |mdf|
      metadata = YAML.load(mdf.get_input_stream.read)
      path = mdf.name.split('/')

      pkg_name = metadata[:title] || path[-3]
      pkg_version = metadata[:version] || path[-2]

      puts "Processing #{repo_name_for_tag}/#{pkg_name}/#{pkg_version}"
      gp = GridwarePackage.from_metadata(metadata, alces,pkg_name, pkg_version)
      gp.save!
      unless gp.tags.include?(tag)
        gp.tags << tag
      end
    end
  end
end

namespace :gridware do

  desc 'Erase current Gridware packages and reimport metadata from GitHub'
  task :import => :environment do

    GridwarePackage.delete_all

    do_gridware_import

  end

  desc 'Update Gridware packages by importing metadata from GitHub'
  task :update => :environment do
      do_gridware_import
  end
end
