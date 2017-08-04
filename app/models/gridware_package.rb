class GridwarePackage < ApplicationRecord
  include Taggable
  belongs_to :user

  GRIDWARE_PACKAGE_TYPES = %w(apps libs compilers mpi ext)

  validates :package_type, inclusion: {
      in: GRIDWARE_PACKAGE_TYPES,
      message: '%{value} is not a valid Gridware package type'
  }

  validates :name,
            presence: true,
            length: {
                maximum: 512
            }

  validates :version,
            presence: true,
            uniqueness: {
                scope: [:name, :package_type]
            },
            length: {
                maximum: 64
            }

  # Update or create record in database from given metadata and user.
  def self.from_metadata(md, user, name_fallback='', version_fallback='')
    GridwarePackage.where(
      user: user,
      name: md[:title] || name_fallback,
      version: md[:version] || version_fallback
    ).first_or_create.tap { |gp|
      gp.user = user
      gp.package_type = md[:type]
      gp.summary = md[:summary]
      gp.url = md[:url]
      gp.description = md[:description]
      gp.group = md[:group]
      gp.changelog = md[:changelog]
    }
  end

end
Gridware = GridwarePackage
