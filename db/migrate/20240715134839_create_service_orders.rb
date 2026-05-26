class CreateServiceOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :service_orders do |t|
      t.datetime :service_order_date
      t.integer :billing_address_id
      t.float :retention
      t.float :tds
      t.float :qc
      t.float :payment_tenure
      t.float :advance_amount
      t.string :related_to
      t.integer :site_id
      t.integer :vendor_id
      t.integer :created_by_id
      t.string :reference
      t.boolean :active
      t.boolean :approved_status
      t.float :total_amount

      t.timestamps
    end
  end
end
