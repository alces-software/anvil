class AddPackageDependencies < ActiveRecord::Migration[5.1]
  def change
    create_table :package_dependencies, id: false do |t|
      t.uuid :parent_id
      t.uuid :dependent_id
    end

    add_index :package_dependencies, :parent_id
    add_index :package_dependencies, :dependent_id
  end
end
