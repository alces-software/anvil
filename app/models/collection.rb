class Collection < ApplicationRecord

  belongs_to :user

  validates :name,
            presence: true,
            length: {
                maximum: 512
            },
            uniqueness: {
                scope: :user
            }

  has_many :collection_memberships

  has_many :gridware_packages, through: :collection_memberships, source: :collectable, source_type: 'GridwarePackage'
  has_many :customizers, through: :collection_memberships, source: :collectable, source_type: 'Customizer'
end
