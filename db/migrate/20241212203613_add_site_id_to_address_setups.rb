class AddSiteIdToAddressSetups < ActiveRecord::Migration[5.1]
  def change
    add_column :address_setups, :site_id, :integer
  end
end
