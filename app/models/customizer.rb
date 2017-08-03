class Customizer < ApplicationRecord
  belongs_to :user

  has_many :taggings, as: :taggable
  has_many :tags, through: :taggings

  validates :name,
            presence: true,
            length: {
                maximum: 512
            },
            uniqueness: {
                scope: :user
            }

  validates :s3_url, presence: true
end
