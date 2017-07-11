class GridwarePackage < ApplicationRecord

  GRIDWARE_PACKAGE_TYPES = %w(apps libs compilers)

  validates :type, inclusion: {
      in: GRIDWARE_PACKAGE_TYPES,
      message: '%{value} is not a valid Gridware package type'
  }
end
