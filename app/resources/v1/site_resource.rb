module V1
  class SiteResource < ResourceBase
    attributes :name

    has_many :users, always_include_linkage_data: true

    key_type :string

    UUID_REGEX = /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/

    def self.find_by_key(key, options = {})
      if UUID_REGEX.match?(key)
        super
      else
        model = Site.find_by_name(key)
        fail JSONAPI::Exceptions::RecordNotFound.new(key) if model.nil?
        resource_for_model(model).new(model, options[:context])
      end
    end
  end
end
