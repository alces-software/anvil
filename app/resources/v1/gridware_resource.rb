module V1
  class GridwareResource < JSONAPI::Resource
    model_name 'GridwarePackage'

    attributes :name, :group, :version, :summary, :url, :description, :package_type

    has_one :user
  end
end
