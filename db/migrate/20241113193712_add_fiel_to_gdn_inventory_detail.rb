class AddFielToGdnInventoryDetail < ActiveRecord::Migration[5.1]
  def change
    add_column :gdn_inventory_details, :consuming_in_id, :integer
  end
end
