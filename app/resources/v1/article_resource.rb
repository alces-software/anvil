module V1
  class ArticleResource < ResourceBase

    before_create :set_user

    paginator :optional_limit

    attributes :title, :text, :summary, :tag_names
    attributes :updated_at, :created_at

    has_one :user

    def fetchable_fields
      if context[:abridged]
        super - [:text]
      else
        super
      end
    end

    def self.updatable_fields(context)
      super - [:summary]
    end

    def self.creatable_fields(context)
      super - [:summary]
    end

    private

    def set_user
      @model.user = context[:current_user]
    end

  end
end
