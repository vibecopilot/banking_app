class CreateKitchenOrderTickets < ActiveRecord::Migration[5.2]
  def change
    create_table :kitchen_order_tickets do |t|
      t.integer :order_id, null: false
      t.integer :restaurant_menu_id
      t.string  :item_name
      t.integer :quantity, default: 1
      t.string  :status, default: "pending"
      t.text    :notes
      t.integer :created_by_id
      t.datetime :sent_at
      t.datetime :accepted_at
      t.datetime :preparing_at
      t.datetime :ready_at
      t.datetime :served_at
      t.timestamps
    end
    add_index :kitchen_order_tickets, :order_id
    add_index :kitchen_order_tickets, :status
  end
end
