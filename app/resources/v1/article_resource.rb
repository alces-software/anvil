module V1
  class ArticleResource < JSONAPI::Resource
    attributes :title, :text
    attributes :updated_at, :created_at

    has_one :user
  end
end
