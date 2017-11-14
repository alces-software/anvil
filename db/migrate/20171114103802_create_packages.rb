class CreatePackages < ActiveRecord::Migration[5.1]
  def change
    create_table :packages, id: :uuid, default: 'gen_random_uuid()' do |t|
      t.uuid :user_id, foreign_key: true
      t.string :name, null: false, limit: 512
      t.string :description
      t.string :summary
      t.text :changelog, null: true
      t.string :licence, limit: 512
      t.string :website

      t.string :package_url, null: false

      t.timestamps
    end

    add_index :packages, [:name, :user_id], unique: true
  end
end
