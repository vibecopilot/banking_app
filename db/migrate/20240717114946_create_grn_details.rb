class CreateGrnDetails < ActiveRecord::Migration[5.1]
  def change
    create_table :grn_details do |t|
      t.integer :loi_detail_id
      t.integer :vendor_id
      t.string :payment_mode
      t.string :invoice_number
      t.string :related_to
      t.float :invoice_amount
      t.datetime :invoice_date
      t.datetime :posting_date
      t.float :other_expenses
      t.float :loading_expenses
      t.float :adjustment_amount
      t.text :notes

      t.timestamps
    end
  end
end
