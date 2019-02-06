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

    # Determine the file type of the content
    if params.include?(:package)
      upload_package
    elsif params.include?(:document)
      upload_document
    else
      raise InvalidUploadException, 'Required parameter not found for upload'
    end
  end

  def upload_document
    path = document_param.path
    document = Document.create(name: document_name, site: current_user.site)
    document.upload_from_path(path)
    render json: document
  end

  def upload_package
    path = package_param.path
    package = Package.where_zip(file: path, user: current_user).first
    package = if package.nil?
                Package.build_from_zip(file: path, user: current_user)
              else
                package.tap { |x| x.zip_file_path = path }
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

  def document_param
    params.require(:document)
  end

  def document_name
    params.fetch(:name) do
      document_param.original_filename ||
        "Untitled Document (#{Time.now.strftime('%Y-%m-%d %H:%M:%S')})"
    end
  end

  def uploaded_zip
    Zip::File.open(package_param.path) do |z| yield(z) end
  end
end
