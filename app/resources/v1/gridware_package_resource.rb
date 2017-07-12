module V1
  class GridwarePackageResource < JSONAPI::Resource
    attributes :name, :group, :version, :summary, :url, :description, :package_type

    has_one :user
  end
end
