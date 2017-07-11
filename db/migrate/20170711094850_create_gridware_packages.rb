class CreateGridwarePackages < ActiveRecord::Migration[5.1]
  def change
    create_table :gridware_packages, id: :uuid, default: 'gen_random_uuid()' do |t|
      t.string :name, null: false
      t.string :group
      t.string :version, null: false
      t.string :summary
      t.string :url
      t.string :description
      t.string :package_type, null: false

      t.timestamps
    end

    add_index :gridware_packages, [:name, :version, :package_type], unique: true
  end
end
