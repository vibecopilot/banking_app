class CreateGdnDetails < ActiveRecord::Migration[5.1]
  def change
    create_table :gdn_details do |t|
      t.date :gdn_date
      t.text :description
      t.boolean :status
      t.integer :created_by_id

      t.timestamps
    end
  end
end
