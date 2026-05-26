class CreateIngredients < ActiveRecord::Migration[5.2]
  def change
    create_table :ingredients do |t|
      t.string  :name
      t.string  :sku
      t.string  :category
      t.string  :unit
      t.decimal :stock_quantity, precision: 12, scale: 3, default: 0.0
      t.decimal :minimum_stock, precision: 12, scale: 3, default: 0.0
      t.decimal :unit_price, precision: 10, scale: 2, default: 0.0
      t.integer :supplier_id
      t.integer :site_id
      t.integer :created_by_id
      t.timestamps
    end
    add_index :ingredients, :supplier_id
    add_index :ingredients, :site_id
    add_index :ingredients, :category
  end
end
