class AddForeignKeys < ActiveRecord::Migration[5.1]
  def change
    add_foreign_key :articles, :users
    add_foreign_key :customizers, :users
    add_foreign_key :gridware_packages, :users
    add_foreign_key :taggings, :tags
  end
end
