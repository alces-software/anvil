
require 'zip'

class Package < ApplicationRecord
  class << self
    def build_from_zip(file:, **input_args)
      new(zip_file_path: file, **input_args).tap do |p|
        p.set_missing_attributes_from_zip
      end
    end

    def from_package_path(path)
      package_props = split_package_path(path)
      user = User.find_by_name(package_props[:user])
      candidates = Package.where(user: user, name: package_props[:package])

      if package_props[:version]
        candidates.find_by_version(package_props[:version])
      else
        candidates.order(version: :desc).first
      end
    end

    private

    def split_package_path(path)
      match = /(?<user>[^\/]+)\/(?<package>[^\/]+)(\/(?<version>[^\/]+))?/.match(path)

      raise 'Unrecognised package format. Please specify as username/packagename[/version]' unless match

      match
    end
  end

  # This path is only used on the upload to validate the zip file is valid
  # As it is not the permanent path, it is not stored in the database
  attr_accessor :zip_file_path

  include Taggable
  belongs_to :user
  belongs_to :category

  validates :name,
            presence: true,
            length: {
                maximum: 512
            }

  validates :version,
            presence: true,
            uniqueness: {
                scope: [:user, :name]
            }

  validates :licence,
            length: {
                maximum: 512
            }

  validates :package_url,
            presence: true

  validate :validate_dependencies

  # The following validators only apply on create when the zip file needs
  # to be validated
  with_options on: :create do |create|
    validates :zip_file_path, presence: true
    validate :validate_zip_contains_installer
    validate :validate_zip_type_is_package
    validate :validate_record_is_consistent_with_zip
  end

  def username
    # Convenience method to embed username in package resource without including everything to do with user
    user.name
  end

  def set_missing_attributes_from_zip
    zip_metadata['attributes']&.each do |key, value|
      setter = :"#{key}="
      next unless respond_to?(setter)
      next if public_send(key)
      public_send(setter, value)
    end
  end

  private

  # This method returns the zip object for the file
  # It only works if the zip_file_path has been set
  def zip
    return nil unless zip_file_path
    @zip ||= begin
      Zip::File.open(zip_file_path)
    end
  end

  def validate_dependencies
    # Check that each listed dependency is a valid package path and points to an actual package.
    # Note: this will not prevent a dependency from being deleted, leaving us invalid, so clients can't assume that
    # every dependency listed here still exists (although in general deleting something that's already been published
    # is poor form).
    dependencies.each do |dep|
      begin
        if Package.from_package_path(dep).nil?
          errors.add(:dependencies, "Dependency '#{dep}' cannot be found")
        end
      rescue
          errors.add(:dependencies, "Dependency '#{dep}' could not be parsed")
      end
    end
  end

  def validate_zip_contains_installer
    return if zip.find_entry('install.sh')
    errors.add(:zip, 'The zip files is missing the "install.sh" script')
  end

  def validate_zip_type_is_package
    return if zip_metadata['type'] == 'package'
    errors.add(:zip, 'The zip files is not of type "package"')
  end

  # This ensures the various attributes are the same in the db and the zip
  def validate_record_is_consistent_with_zip
    ['name', 'version'].each do |attr|
      next if public_send(attr) == zip_metadata['attributes']&.[](attr)
      errors.add(:zip, "The zip value for '#{attr}' does not match")
    end
  end

  def zip_metadata
    @zip_metadata ||= begin
      JSON.parse(zip.read(zip.get_entry('metadata.json')))
    end
  end
end

