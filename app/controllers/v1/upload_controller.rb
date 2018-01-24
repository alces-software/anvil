require 'alces/anvil/s3_utils'
require 'json'
require 'zip'

class V1::UploadController < ApplicationController

  class InvalidUploadException < Exception; end

  rescue_from InvalidUploadException do |exception|
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

    package = uploaded_zip do |z|
      validate_contents(z)
      metadata = metadata_from(z)

      validate_metadata(metadata)
      attrs = metadata['attributes']

      package = Package.where(user: current_user, name: attrs['name'], version: attrs['version']).first_or_create

      set_attributes(package, attrs)

      package.package_url = ::Alces::Anvil::S3Utils.url_for(package)
      p package
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

  def uploaded_zip
    Zip::File.open(params[:package].path) do |z| yield(z) end
  end

  def metadata_from(zip)
    JSON.parse(zip.read(zip.get_entry('metadata.json')))
  end

  def validate_contents(zip)
    check(zip.find_entry('install.sh'), 'Package must contain an install.sh script')
    check(zip.find_entry('metadata.json'), 'Package must contain a metadata.json file')
  end

  def validate_metadata(metadata)
    check(metadata.include?('type'), 'Must be in correct format (missing key: type)')
    check(metadata['type'] == 'packages', 'Must be of type=packages')
    check(metadata.include?('attributes'), 'Must be in correct format (missing key: attributes')
    validate_attributes(metadata['attributes'])
  end

  def validate_attributes(attrs)
    check(attrs.include?('name'), 'Package metadata must specify a name')
    check(attrs.include?('version'), 'Package metadata must specify a version')
  end

  def set_attributes(package, attrs)
    attrs.each do |key, value|
      setter = "#{key.underscore}=".to_sym
      if package.respond_to?(setter)
        package.send(setter, value)
      end
    end
  end

  def check(condition, message)
    raise InvalidUploadException.new(message) unless condition
  end
end
