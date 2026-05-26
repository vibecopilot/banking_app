class AddInvoiceTypeToCamBill < ActiveRecord::Migration[5.1]
  def change
    add_column :cam_bills, :invoice_type, :string
    add_column :cam_bills, :invoice_address_id, :integer
    add_column :cam_bills, :invoice_number, :string
    add_column :cam_bills, :building_id, :integer
    add_column :cam_bills, :flat_id, :integer
    add_column :cam_bills, :due_amount, :float
    add_column :cam_bills, :due_amount_interst, :float
    add_column :cam_bills, :note, :text
    add_column :cam_bill_charges, :discount_percent, :integer
    add_column :cam_bill_charges, :quantity, :float
    add_column :cam_bill_charges, :unit, :float
    add_column :cam_bill_charges, :rate, :float
    add_column :cam_bill_charges, :hsn_id, :integer
    add_column :cam_bill_charges, :taxable_value, :float
  end
end
