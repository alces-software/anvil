
require 'zip'

class Package < ApplicationRecord
  class << self
    def build_from_zip(file:, **input_args)
      default_args = extract_metadata(file).attributes.to_h.symbolize_keys
      args = OpenStruct.new(default_args.merge(input_args))
      args.zip_file_path = file
      new(name: args.name, version: args.version).tap do |p|
        set_attributes(p, args)
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

    def extract_metadata(file)
      zip = Zip::File.open(file)
      JSON.parse(
        zip.read(zip.get_entry('metadata.json')),
        object_class: OpenStruct
      )
    end

    def set_attributes(package, attrs)
      attrs.to_h.each do |key, value|
        setter = "#{key.to_s.underscore}=".to_sym
        if package.respond_to?(setter)
          package.send(setter, value)
        end
      end
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

  def username
    # Convenience method to embed username in package resource without including everything to do with user
    user.name
  end

  private

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
end

