class RenameSupplierColumnsInVendors < ActiveRecord::Migration[5.1]
  def change
    rename_column :vendors, :supplier_type_id, :vendor_supplier_id
    rename_column :vendors, :supplier_sub_type_id, :vendor_categories_id
  end
end
