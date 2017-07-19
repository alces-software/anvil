class AddUserToArticles < ActiveRecord::Migration[5.1]
  def change
    change_table :articles do |t|
      t.uuid :user_id, null: false, foreign_key: true
    end
  end
end
