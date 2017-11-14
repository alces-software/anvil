class Package < ApplicationRecord
  include Taggable
  belongs_to :user

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
end
