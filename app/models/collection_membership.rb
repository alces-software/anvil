class CollectionMembership < ApplicationRecord
  belongs_to :collection
  belongs_to :collectable, polymorphic: true
end
