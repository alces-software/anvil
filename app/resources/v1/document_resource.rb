module V1
  class DocumentResource < ResourceBase
    attributes :name, :url, :content_type

    belongs_to :site
  end
end
