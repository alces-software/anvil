require 'open-uri'
require 'yaml'
require 'zip'

namespace :gridware do
  desc 'Import Gridware package metadata from a Git checkout'
  task :import => :environment do

    remote_zip = open('https://github.com/alces-software/gridware-packages-main/archive/master.zip')

    ::Zip::File.open_buffer(remote_zip) do | zipfile |
      metadata_files = zipfile.glob('**/metadata.yml')
      metadata_files.each do |mdf|
        metadata = YAML.load(mdf.get_input_stream().read())
        gp = GridwarePackage.from_metadata(metadata)
        gp.save
      end

    end
  end
end
