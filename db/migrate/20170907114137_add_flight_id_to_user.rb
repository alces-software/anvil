class AddFlightIdToUser < ActiveRecord::Migration[5.1]
  def change
    change_table :users do |t|
      t.uuid :flight_id, null: false
    end
  end
end
