require 'aws-sdk-s3'

module Alces
  module Anvil
    class S3Utils
      class << self

        def url_for(package)
          object_for(package).public_url
        end

        def upload_package(package, payload)
            obj = object_for(package)
            obj.upload_file(payload.path)
            obj.acl.put({ acl: 'public-read' })
        end

        private

        def s3
          @s3 ||= Aws::S3::Resource.new({region: 'eu-west-1'})
        end

        def bucket
          @bucket ||= s3.bucket(ENV['AWS_FORGE_ROOT_BUCKET'])
        end

        def object_name_for(package)
          "#{package.user.name}/#{package.name}/#{package.version}.zip"
        end

        def object_for(package)
          bucket.object(object_name_for(package))
        end

      end
    end
  end
end
