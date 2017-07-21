module V1
  class ArticleResource < JSONAPI::Resource

    paginator :optional_limit

    attributes :title, :text
    attributes :updated_at, :created_at

    has_one :user

  end
end
