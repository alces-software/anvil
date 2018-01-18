module V1
  class PackageResource < ResourceBase

    paginator :optional_limit

    attributes :name, :summary, :description,
               :dependencies, :changelog, :licence, :tag_names,
               :package_url, :website, :version
    attributes :username

    attributes :updated_at, :created_at


    has_one :user
    has_one :category

    filters :name, :version
    filter :username, apply: ->(records, value, _options) {
      records.joins(:user).where(users: { name: value[0] })
    }

    def self.updatable_fields(context)
      super - [:username]
    end

    def self.creatable_fields(context)
      super - [:username]
    end

  end
end
