class RemoveVtypeFromVendors < ActiveRecord::Migration[5.1]
  def change
    remove_column :vendors, :vtype, :string
  end
end
