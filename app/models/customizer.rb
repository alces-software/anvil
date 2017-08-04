class Customizer < ApplicationRecord
  include Taggable

  belongs_to :user

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
