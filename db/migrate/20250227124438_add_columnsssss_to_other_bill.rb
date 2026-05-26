class AddColumnsssssToOtherBill < ActiveRecord::Migration[5.1]
  def change
    add_column :other_bills, :amount, :float
    add_column :other_bills, :base_amount, :float
    add_column :other_bills, :tds_rate, :float
    add_column :other_bills, :tds_amount, :float
  end
end
