class AddColumnsToLoiServices < ActiveRecord::Migration[5.1]
  def change
    add_column :loi_services, :csgt_rate, :float
    add_column :loi_services, :csgt_amt, :float
    add_column :loi_services, :sgst_rate, :float
    add_column :loi_services, :sgst_amt, :float
    add_column :loi_services, :igst_rate, :float
    add_column :loi_services, :igst_amt, :float
    add_column :loi_services, :tcs_rate, :float
    add_column :loi_services, :tcs_amt, :float
    add_column :loi_services, :tax_amt, :float    
  end
end
