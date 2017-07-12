class User < ApplicationRecord
  has_many :gridware_packages

  validates :name, uniqueness: true
end