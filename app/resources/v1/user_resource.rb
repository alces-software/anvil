module V1
  class UserResource < JSONAPI::Resource
    attributes :name

    # Allow accessing user by username not ID
    primary_key :name
    key_type :string

    has_many :gridware_packages
  end
end
