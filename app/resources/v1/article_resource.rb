module V1
  class ArticleResource < ResourceBase

    before_create :set_user

    paginator :optional_limit

    attributes :title, :text
    attributes :updated_at, :created_at

    has_one :user

    private

    def set_user
      @model.user = context[:current_user]
    end

  end
end
