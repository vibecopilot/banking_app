class CreatePurchaseOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :purchase_orders do |t|
      t.string  :order_number
      t.integer :supplier_id
      t.date    :order_date
      t.string  :status, default: "draft"
      t.decimal :total_amount, precision: 12, scale: 2, default: 0.0
      t.text    :notes
      t.integer :site_id
      t.integer :created_by_id
      t.timestamps
    end
    add_index :purchase_orders, :supplier_id
    add_index :purchase_orders, :site_id
    add_index :purchase_orders, :status
    add_index :purchase_orders, :order_number, unique: true
  end
end
