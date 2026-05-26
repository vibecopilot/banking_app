class AddSupplierTypeToVendors < ActiveRecord::Migration[5.1]
  def change
    add_reference :vendors, :supplier_type, foreign_key: { to_table: :generic_infos }
    add_reference :vendors, :supplier_sub_type, foreign_key: { to_table: :generic_sub_infos }
    #make cahge
  end
end