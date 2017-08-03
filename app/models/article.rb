class Article < ApplicationRecord
  belongs_to :user

  has_many :taggings, as: :taggable
  has_many :tags, through: :taggings

  def summary
    if text.length <= 255
      text
    else
      text[0..255] + '…'
    end
  end
end
