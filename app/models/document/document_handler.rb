require 'aws-sdk-s3'
require 'mimemagic'
require 'mimemagic/overlay'

class Document
  class DocumentHandler
    class << self
      def presigner
        @presigner ||= Aws::S3::Presigner.new(client: s3)
      end

      def bucket
        @bucket ||=
          Aws::S3::Resource.new(client: s3)
            .bucket(
              ENV.fetch('FLIGHT_REPO_DOCS_BUCKET','alces-flight-center')
            )
      end

      private
      def s3
        @s3 ||= Aws::S3::Client.new(
          region: ENV.fetch('FLIGHT_REPO_DOCS_REGION','eu-west-2')
        )
      end
    end

    delegate :presigner, :bucket, to: self

    def initialize(document)
      @document = document
    end

    def signed_url
      presigner.presigned_url(
        :get_object,
        bucket: bucket.name,
        key: object_name,
        expires_in: 60.minutes.to_i
      )
    end

    def upload_from_path(path)
      @document.update(content_type: content_type_for(path))
      object.upload_file(path, content_type: @document.content_type)
    end

    private

    def content_type_for(path)
      File.open(path, 'rb') { |f| MimeMagic.by_magic(f) } ||
        MimeMagic.by_path(@document.name) ||
        IO.popen(["file", "--brief", "--mime-type", path], &:read).chomp
    end

    def object_name
      "repo/sites/#{@document.site.name}/docs/#{@document.name}"
    end

    def object
      bucket.object(object_name)
    end
  end
end
