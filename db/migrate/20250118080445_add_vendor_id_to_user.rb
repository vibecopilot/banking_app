class AddVendorIdToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :vendor_id, :integer
  end
end
