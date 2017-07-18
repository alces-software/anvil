class Customizer < ApplicationRecord
  belongs_to :user

  validates :name,
            presence: true,
            length: {
                maximum: 512
            }

  validates :s3_url, presence: true
end
