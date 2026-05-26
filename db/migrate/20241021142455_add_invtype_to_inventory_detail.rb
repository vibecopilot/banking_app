class AddInvtypeToInventoryDetail < ActiveRecord::Migration[5.1]
  def change
    add_column :inventory_details, :inventory_type, :integer
    add_column :inventory_details, :criticality, :integer
  end
end
