class AddGrnUniqueIdToGrnDetails < ActiveRecord::Migration[5.1]
  def change
    add_column :grn_details, :grn_unique_id, :string
    add_index :grn_details, :grn_unique_id, unique: true
  end
end
