require 'alces/anvil/s3_utils'
require 'json'
require 'zip'

class V1::UploadController < ApplicationController

  class InvalidUploadException < Exception; end

  rescue_from InvalidUploadException, JSON::ParserError do |exception|
    error_object = {
        title: 'Invalid upload',
        detail: exception.message,
        code: 'invalid',
        status: 400
    }
    render json: {errors: [error_object]}, status: :bad_request
  end

  def upload
    raise CanCan::AccessDenied.new('You must be logged in to upload files.') unless current_user

    path = package_param.path
    package = Package.where_zip(file: path, user: current_user)
                     .find_or_create_by(nil) do |p|
                       p.zip_file_path = path
                       p.set_missing_attributes_from_zip
                     end

    uploaded_zip do |z|
      package.package_url = ::Alces::Anvil::S3Utils.url_for(package)
      package.save!  # We need to save the package to let the PackageResource generate properly

      resource = V1::PackageResource.new(package, { current_user: current_user})
      serializer = JSONAPI::ResourceSerializer.new(V1::PackageResource, base_url: base_url)
      new_metadata = serializer.serialize_to_hash(resource)[:data]

      z.get_output_stream('metadata.json') do |os|
        os.write(new_metadata.to_json)
      end

      package
    end

    ::Alces::Anvil::S3Utils.upload_package(package, params[:package])
  end

  private

  def base_url
    request.protocol + request.host_with_port
  end

  def package_param
    params.require(:package)
  end

  def uploaded_zip
    Zip::File.open(package_param.path) do |z| yield(z) end
  end
end
