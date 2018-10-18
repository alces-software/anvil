class RemoveCategoriesDefault < ActiveRecord::Migration[5.1]
  def change
    change_column_default 'packages', 'category_id', nil
  end
end
