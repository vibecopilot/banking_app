class AddParentIdToVisitor < ActiveRecord::Migration[5.1]
  def change
    add_column :visitors, :parent_id, :integer
  end
end
