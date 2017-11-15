class Tag < ApplicationRecord

  validates :id, format: { with: /\A[a-z_0-9]+\z/ }

  has_many :taggings

  has_many :articles, through: :taggings, source: :taggable, source_type: 'Article'
  has_many :packages, through: :taggings, source: :taggable, source_type: 'Package'

  def self.get_or_create(tag)
    Tag.find_by_id(tag.downcase) || Tag.create(id: tag.downcase)
  end

end
