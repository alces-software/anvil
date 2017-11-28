class Category < ApplicationRecord

  belongs_to :parent, class_name: 'Category', foreign_key: 'parent_id'

  validates :name,
            presence: true,
            length: {
                maximum: 64
            }

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
