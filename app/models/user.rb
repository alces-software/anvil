class User < ApplicationRecord
  has_many :gridware_packages
  has_many :customizers

  validates :name, uniqueness: true

  alias_attribute :gridware, :gridware_packages
end
