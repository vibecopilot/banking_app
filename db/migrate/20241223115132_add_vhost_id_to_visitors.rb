class AddVhostIdToVisitors < ActiveRecord::Migration[5.1]
  def change
    add_column :visitors, :vhost_id, :integer
    add_index :visitors, :vhost_id  # Optional: Add an index for better query performance
  end
end
