class AddFieldsToGdnInventoryDetail < ActiveRecord::Migration[5.1]
  def change
    add_column :gdn_inventory_details, :purpose_id, :integer
    add_column :gdn_inventory_details, :handover_to_id, :integer
  end
end
