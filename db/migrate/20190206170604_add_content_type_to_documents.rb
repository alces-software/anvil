class AddContentTypeToDocuments < ActiveRecord::Migration[5.1]
  def change
    change_table :documents do |t|
      t.string :content_type, null: true, default: nil, limit: 255
    end
  end
end
