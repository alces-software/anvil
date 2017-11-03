class AddLicenceToGridware < ActiveRecord::Migration[5.1]
  def change
    add_column :gridware_packages, :licence, :string, limit: 255
  end
end
