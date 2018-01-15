module V1
  class PackageResource < ResourceBase

    paginator :optional_limit

    attributes :name, :summary, :description,
               :changelog, :licence, :tag_names,
               :package_url, :website, :version

    attributes :updated_at, :created_at

    has_one :user
    has_one :category

    has_many :dependencies, always_include_linkage_data: true

    filters :name, :version
    filter :username, apply: ->(records, value, _options) {
      records.joins(:user).where(users: { name: value[0] })
    }

  end
end
