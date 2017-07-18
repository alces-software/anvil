module V1
  class CustomizerResource < JSONAPI::Resource

    paginator :optional_limit

    attributes :name, :description, :s3_url
    attributes :updated_at, :created_at

    has_one :user


  end
end
