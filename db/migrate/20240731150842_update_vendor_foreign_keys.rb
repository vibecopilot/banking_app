class UpdateVendorForeignKeys < ActiveRecord::Migration[5.1]
  def change
    remove_foreign_key :vendors, column: :vendor_supplier_id
    remove_foreign_key :vendors, column: :vendor_categories_id

    add_foreign_key :vendors, :generic_sub_infos, column: :vendor_supplier_id
    add_foreign_key :vendors, :generic_sub_infos, column: :vendor_categories_id
  end
end
