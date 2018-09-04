
require 'json'
require 'zip'
require 'tempfile'

module Helpers
  module ZipMaker
    class << self
      def with_metadata(path, **content)
        content = JSON.dump(content)
        Zip::File.open(path, Zip::File::CREATE) do |zip_file|
          zip_file.get_output_stream('metadata.json') do |f|
            f.write(content)
          end
        end
      end
    end
  end
end
