class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users, id: :uuid, default: 'gen_random_uuid()' do |t|
      t.string :name, index: { unique: true }

      t.timestamps
    end

    change_table :gridware_packages do |t|
      t.uuid :user_id, index: true, foreign_key: true
    end

  end
end
