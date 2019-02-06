class CreateDocuments < ActiveRecord::Migration[5.1]
  def change
    create_table :documents, id: :uuid, default: 'gen_random_uuid()' do |t|
      t.string :name, null: false, limit: 512
      t.uuid :site_id, index: true, foreign_key: true
    end
  end
end
