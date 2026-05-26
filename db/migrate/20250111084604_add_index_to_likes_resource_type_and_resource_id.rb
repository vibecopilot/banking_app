class AddIndexToLikesResourceTypeAndResourceId < ActiveRecord::Migration[5.1]
  def change
    add_index :likes, [:resource_type, :resource_id]
  end
end
