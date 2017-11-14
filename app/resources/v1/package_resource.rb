module V1
  class PackageResource < ResourceBase

    paginator :optional_limit

    attributes :name, :summary, :description,
               :changelog, :licence, :tag_names,
               :package_url, :website, :version

    attributes :updated_at, :created_at

    has_one :user


  end
end
