require 'open-uri'
require 'yaml'
require 'zip'

GRIDWARE_ZIP_URL = 'https://github.com/alces-software/gridware-packages-main/archive/master.zip'

def do_import
  remote_zip = open(GRIDWARE_ZIP_URL)

  alces = User.find_by_name('alces')

  ::Zip::File.open_buffer(remote_zip) do | zipfile |
    metadata_files = zipfile.glob('**/metadata.yml')
    metadata_files.each do |mdf|
      metadata = YAML.load(mdf.get_input_stream().read())
      path = mdf.name.split('/')

      pkg_name = metadata[:title] || path[-3]
      pkg_version = metadata[:version] || path[-2]

      gp = GridwarePackage.from_metadata(metadata, alces,pkg_name, pkg_version)
      gp.save!
    end
  end
end

namespace :gridware do

  desc 'Erase current Gridware packages and reimport metadata from GitHub'
  task :import => :environment do

    GridwarePackage.delete_all

    do_import

  end

  desc 'Update Gridware packages by importing metadata from GitHub'
  task :update => :environment do
      do_import
  end
end
