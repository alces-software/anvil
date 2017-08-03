class CreateTags < ActiveRecord::Migration[5.1]
  def change
    # A tag is its own ID
    # It might seem redundant to have its own table but it makes Rails associations easier
    create_table :tags, id: :string

    create_table :taggings do |t|
      t.string :tag_id, null: false, foreign_key: true
      t.uuid :taggable_id, null: false
      t.string :taggable_type, null: false
    end

    add_index :taggings, [:taggable_id, :taggable_type]
  end
end
