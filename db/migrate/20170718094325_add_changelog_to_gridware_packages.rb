class AddChangelogToGridwarePackages < ActiveRecord::Migration[5.1]
  def change
    change_table :gridware_packages do |t|
      t.text :changelog, null: true, default: nil
    end
  end
end
