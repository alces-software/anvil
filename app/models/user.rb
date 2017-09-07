class User < ApplicationRecord

  has_many :articles
  has_many :customizers
  has_many :gridware_packages

  validates :name, uniqueness: true

  alias_attribute :gridware, :gridware_packages

end
