module V1
  class ArticleResource < ResourceBase

    before_create :set_user

    paginator :optional_limit

    attributes :title, :text, :summary
    attributes :updated_at, :created_at

    has_one :user

    def self.updatable_fields(context)
      super - [:summary]
    end

    def self.creatable_fields(context)
      super - [:summary]
    end

    def summary
      if text.length <= 255
        text
      else
        text[0..255] + '…'
      end
    end

    private

    def set_user
      @model.user = context[:current_user]
    end

  end
end
