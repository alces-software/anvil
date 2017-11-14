class Package < ApplicationRecord
  include Taggable
  belongs_to :user

  validates :name,
            presence: true,
            length: {
                maximum: 512
            },
            uniqueness: {
                scope: [:user]
            }

  validates :licence,
            length: {
                maximum: 512
            }

  validates :package_url,
            presence: true
end
