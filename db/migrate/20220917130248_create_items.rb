class CreateItems < ActiveRecord::Migration[5.1]
  def change
    create_table :items do |t|
      t.integer :site_id
      t.string :name
      t.text :description
      t.float :rate
      t.integer :available_quantity
      t.integer :created_by_id

      t.timestamps
    end
  end
end
