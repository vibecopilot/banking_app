class CreatePantries < ActiveRecord::Migration[5.1]
  def change
    create_table :pantries do |t|
      t.string :item_name
      t.integer :stock
      t.text :description
      t.integer :created_by_id
      t.boolean :status

      t.timestamps
    end
  end
end
