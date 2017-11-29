class Category < ApplicationRecord

  belongs_to :parent, class_name: 'Category', foreign_key: 'parent_id', optional: true

  validates :name,
            presence: true,
            length: {
                maximum: 64
            },
            uniqueness: true

  def with_all_parents
    collector = []
    current = self

    while current
      collector << current
      current = current.parent
    end
    collector
  end
end
