
require 'json'
require 'zip'
require 'tempfile'

module Helpers
  module ZipMaker
    class << self
      def with_metadata(path, **content)
        content = JSON.dump(content)
        zip_open(path) do |zip_file|
          zip_file.get_output_stream('metadata.json') do |f|
            f.write(content)
          end
        end
      end

      def with_installer(path)
        zip_open(path) do |zip_file|
          zip_file.get_output_stream('install.sh') { |f| f.write('') }
        end
      end

      private

      def zip_open(path)
        flag = (File.size?(path) ? nil : Zip::File::CREATE)
        Zip::File.open(path, flag) { |f| yield f }
      end
    end
  end
end
