class CreateGridwarePackages < ActiveRecord::Migration[5.1]
  def change
    create_table :gridware_packages, id: :uuid, default: 'gen_random_uuid()' do |t|
      t.string :name
      t.string :group
      t.string :version
      t.string :summary
      t.string :url
      t.string :description
      t.string :package_type

      t.timestamps
    end
  end
end
