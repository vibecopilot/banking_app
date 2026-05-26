class AddFloorColumnToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :floor_id, :integer
  end
end
