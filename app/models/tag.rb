class Tag < ApplicationRecord

  has_many :taggings

  has_many :articles, through: :taggings, source: :taggable, source_type: 'Article'
  has_many :customizers, through: :taggings, source: :taggable, source_type: 'Customizer'
  has_many :gridware_packages, through: :taggings, source: :taggable, source_type: 'GridwarePackage'

  def self.get_or_create(tag)
    Tag.find_by_id(tag) || Tag.create(id: tag)
  end

end
