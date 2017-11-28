class CreateCategories < ActiveRecord::Migration[5.1]

  class Category < ApplicationRecord
  end

  def change
    create_table :categories, id: :uuid, default: 'gen_random_uuid()' do |t|
      t.string :name, null: false, limit: 64
      t.uuid :parent_id, null: true

      t.timestamps
    end

    add_foreign_key :categories, :categories, column: :parent_id

    uncat = Category.where(name: 'Uncategorised').first_or_create

    add_column :packages, :category_id, :uuid, null: false, default: uncat.id
    add_foreign_key :packages, :categories
  end
end
