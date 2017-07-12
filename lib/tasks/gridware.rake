require 'open-uri'
require 'yaml'
require 'zip'

namespace :gridware do
  desc 'Erase current Gridware packages and reimport metadata from GitHub'
  task :import => :environment do

    remote_zip = open('https://github.com/alces-software/gridware-packages-main/archive/master.zip')

    GridwarePackage.delete_all

    alces = User.find_by_name('alces')

    ::Zip::File.open_buffer(remote_zip) do | zipfile |
      metadata_files = zipfile.glob('**/metadata.yml')
      metadata_files.each do |mdf|
        metadata = YAML.load(mdf.get_input_stream().read())
        path = mdf.name.split('/')
        gp = GridwarePackage.from_metadata(metadata, path[-3], path[-2])
        gp.user = alces
        gp.save!
      end

    end
  end
end
