class Document < ApplicationRecord
  belongs_to :site

  def url
    "http://foobar.com"
  end
end
