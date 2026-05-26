class CreateLoiServices < ActiveRecord::Migration[5.1]
  def change
    create_table :loi_services do |t|
      t.integer :service_detail_id
      t.string :product_description
      t.float :quantity
      t.float :rate
      t.integer :uom
      t.date :expected_date
      t.float :amount
      t.float :total_amount
      t.string :kind_attention
      t.string :subject
      t.text :description
      t.text :terms_and_conditions
      t.integer :service_order_id

      t.timestamps
    end
  end
end
