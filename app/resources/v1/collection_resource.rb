module V1
  class CollectionResource < ResourceBase
    attributes :name
    attributes :updated_at, :created_at

    has_one :user

    has_many :gridware, class_name: 'Gridware', always_include_linkage_data: true
    has_many :customizers, always_include_linkage_data: true

    before_save do
      @model.user_id = context[:current_user].id if @model.new_record?
    end
  end
end
