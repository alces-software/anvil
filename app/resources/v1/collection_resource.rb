module V1
  class CollectionResource < ResourceBase
    attributes :name
    attributes :updated_at, :created_at

    has_one :user

    has_many :gridware
    has_many :customizers
  end
end
