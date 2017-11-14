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

  has_many :packages, through: :collection_memberships

end
