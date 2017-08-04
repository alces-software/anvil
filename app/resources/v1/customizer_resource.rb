module V1
  class CustomizerResource < ResourceBase

    paginator :optional_limit

    attributes :name, :summary, :description, :s3_url, :tag_names
    attributes :updated_at, :created_at

    has_one :user


  end
end
