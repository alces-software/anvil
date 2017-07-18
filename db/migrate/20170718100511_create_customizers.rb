class CreateCustomizers < ActiveRecord::Migration[5.1]
  def change
    create_table :customizers, id: :uuid, default: 'gen_random_uuid()' do |t|
      t.string :name, null: false, limit: 512
      t.string :description
      t.uuid :user_id, foreign_key: true
      t.string :s3_url, null: false

      t.timestamps
    end
  end
end
