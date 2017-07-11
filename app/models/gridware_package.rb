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

  def self.from_metadata(md, name_fallback='', version_fallback='')
    GridwarePackage.new(
      name: md[:title] || name_fallback,
      version: md[:version] || version_fallback,
      package_type: md[:type],
      summary: md[:summary],
      url: md[:url],
      description: md[:description],
      group: md[:group]
    )
  end
end
