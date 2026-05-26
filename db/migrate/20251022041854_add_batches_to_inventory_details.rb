class AddBatchesToInventoryDetails < ActiveRecord::Migration[5.1]
  def change
    add_column :inventory_details, :batches, :text
  end
end
