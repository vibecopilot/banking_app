class AddVendorIdToLoiDetails < ActiveRecord::Migration[5.1]
  def change
    add_column :loi_details, :vendor_id, :integer
  end
end
