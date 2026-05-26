class AddResourceTypeAndResourceIdToLikes < ActiveRecord::Migration[5.1]
  def change
    add_column :likes, :resource_type, :string
    add_column :likes, :resource_id, :integer
  end
end
