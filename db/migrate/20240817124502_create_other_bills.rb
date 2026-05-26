class CreateOtherBills < ActiveRecord::Migration[5.1]
  def change
    create_table :other_bills do |t|
      t.integer :vendor_id
      t.date :bill_date
      t.string :invoice_number
      t.string :related_to
      t.float :tds_percentage
      t.float :retention_percentage
      t.string :deduction_remarks
      t.float :deduction_amount
      t.float :additional_expenses
      t.integer :payment_tenure
      t.float :cgst_rate
      t.float :cgst_amount
      t.float :sgst_rate
      t.float :sgst_amount
      t.float :igst_rate
      t.float :igst_amount
      t.float :tcs_rate
      t.float :tcs_amount
      t.float :tax_amount
      t.float :total_amount
      t.text :description

      t.timestamps
    end
  end
end
