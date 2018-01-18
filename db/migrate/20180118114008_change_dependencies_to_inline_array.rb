class ChangeDependenciesToInlineArray < ActiveRecord::Migration[5.1]
  def change
    drop_table :package_dependencies

    change_table :packages do |t|
      t.string :dependencies, default:[], array: true
    end
  end
end
