module V1
  class CategoryResource < ResourceBase
    attributes :name

    has_many :ancestors, class_name: 'Category', always_include_linkage_data: true

    def records_for_ancestors(options)
      collector = []
      current = @model.parent

      while current
        collector << current
        current = current.parent
      end
      collector
    end
  end
end
