class Article < ApplicationRecord
  include Taggable

  belongs_to :user

  def summary
    if text.length <= 255
      text
    else
      text[0..255] + '…'
    end
  end
end
