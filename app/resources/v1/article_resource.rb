module V1
  class ArticleResource < JSONAPI::Resource
    attributes :title, :text
    has_one :user
  end
end
