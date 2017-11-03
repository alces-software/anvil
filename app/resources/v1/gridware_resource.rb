module V1
  class GridwareResource < ResourceBase

    model_name 'GridwarePackage'

    paginator :optional_limit

    attributes :name, :group, :version, :summary, :url, :description, :package_type, :changelog, :licence, :tag_names
    attributes :updated_at, :created_at

    has_one :user


  end
end
