class CreateArticles < ActiveRecord::Migration[5.1]
  def change
    enable_extension 'pgcrypto'  # contains gen_random_uuid
    create_table :articles, id: :uuid, default: 'gen_random_uuid()' do |t|
      t.string :title
      t.text :text

      t.timestamps
    end
  end
end
