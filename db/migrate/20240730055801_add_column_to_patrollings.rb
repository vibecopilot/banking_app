class AddColumnToPatrollings < ActiveRecord::Migration[5.1]
  def change
    add_column :patrollings, :floor_id, :integer
    add_column :patrollings, :unit_id, :integer
  end
end
