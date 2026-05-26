class AddDetailToInventories < ActiveRecord::Migration[5.1]
  def change
    add_column :inventories, :site_id, :integer
  end
end
