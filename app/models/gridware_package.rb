class GridwarePackage < ApplicationRecord

  GRIDWARE_PACKAGE_TYPES = %w(apps libs compilers)

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

  def self.from_metadata(md)
    GridwarePackage.new(
      name: md[:title],
      version: md[:version],
      package_type: md[:type],
      summary: md[:summary],
      url: md[:url],
      description: md[:description],
      group: md[:group]
    )
  end
end
