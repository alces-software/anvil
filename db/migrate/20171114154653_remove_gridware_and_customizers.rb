class RemoveGridwareAndCustomizers < ActiveRecord::Migration[5.1]
  def up
    execute 'TRUNCATE TABLE collection_memberships'
    drop_table :gridware_packages
    drop_table :customizers

    remove_index :collection_memberships, name: 'collection_members_idx'
    remove_column :collection_memberships, :collectable_id
    remove_column :collection_memberships, :collectable_type

    add_column :collection_memberships, :package_id, :uuid
    add_foreign_key :collection_memberships, :packages
    add_index :collection_memberships, [:collection_id, :package_id], unique: true
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
