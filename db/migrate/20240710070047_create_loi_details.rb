class CreateLoiDetails < ActiveRecord::Migration[5.1]
  def change
    create_table :loi_details do |t|
      t.string :loi_type
      t.string :reference
      t.date :loi_date
      t.integer :created_by_id
      t.integer :billing_address_id
      t.integer :delivery_address_id
      t.float :transportation_amount
      t.float :retention
      t.float :tds
      t.float :qc
      t.string :related_to
      t.text :terms
      t.boolean :is_approved
      t.integer :site_id

      t.timestamps
    end
  end
end
