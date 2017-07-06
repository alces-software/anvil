module V1
  class ArticleResource < JSONAPI::Resource
    attributes :title, :text
  end
end
