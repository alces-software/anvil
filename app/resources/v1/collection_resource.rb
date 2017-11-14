module V1
  class CollectionResource < ResourceBase
    attributes :name
    attributes :updated_at, :created_at

    has_one :user

    before_save do
      @model.user_id = context[:current_user].id if @model.new_record?
    end
  end
end
