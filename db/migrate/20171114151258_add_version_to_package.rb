class AddVersionToPackage < ActiveRecord::Migration[5.1]
  def change
    add_column :packages, :version, :string

    remove_index :packages, column: [:name, :user_id]
    add_index :packages, [:name, :version, :user_id], unique: true
  end
end
