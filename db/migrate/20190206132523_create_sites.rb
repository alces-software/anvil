class CreateSites < ActiveRecord::Migration[5.1]
  def change
    create_table :sites, id: :uuid, default: 'gen_random_uuid()' do |t|
      t.string :name, index: { unique: true }

      t.timestamps
    end

    change_table :users do |t|
      t.uuid :site_id, index: true, foreign_key: true
    end
  end
end
