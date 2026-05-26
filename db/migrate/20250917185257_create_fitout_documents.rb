class CreateFitoutDocuments < ActiveRecord::Migration[5.1]
  def change
    create_table :fitout_documents do |t|
      t.integer :fitout_request_id
      t.boolean :active , default: true
      t.string :name

      t.timestamps
    end
  end
end
