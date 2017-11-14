module V1
  class UserResource < ResourceBase
    attributes :name

    filter :flight_id

    has_many :articles, always_include_linkage_data: true
    has_many :customizers, always_include_linkage_data: true
    has_many :gridware, class_name: 'Gridware', always_include_linkage_data: true
    has_many :packages, always_include_linkage_data: true

    has_many :collections, always_include_linkage_data: true

    key_type :string

    UUID_REGEX = /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/

    def self.find_by_key(key, options = {})
      if UUID_REGEX.match?(key)
        super
      else
        model = User.find_by_name(key)
        fail JSONAPI::Exceptions::RecordNotFound.new(key) if model.nil?
        resource_for_model(model).new(model, options[:context])
      end
    end
  end
end
