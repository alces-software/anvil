module V1
  class CategoryResource < ResourceBase
    attributes :name

    has_many :ancestors, class_name: 'Category', always_include_linkage_data: true

    def records_for_ancestors(options)
      _, *ancestors = *@model.with_all_parents  # We want all but the head of the array
      ancestors
    end
  end
end
