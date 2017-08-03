class AddSummaryToCustomizer < ActiveRecord::Migration[5.1]
  def change
    change_table :customizers do |t|
      t.string :summary
    end
  end
end
