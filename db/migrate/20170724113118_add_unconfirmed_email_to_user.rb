class AddUnconfirmedEmailToUser < ActiveRecord::Migration[5.1]
  def change
    change_table :users do |t|
      # Devise documentation lies: it says "Only if using reconfirmable". Actually needed for confirmable.
      t.string   :unconfirmed_email
      end
  end
end
