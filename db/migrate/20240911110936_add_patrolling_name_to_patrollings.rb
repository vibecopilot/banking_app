class AddPatrollingNameToPatrollings < ActiveRecord::Migration[5.1]
  def change
    add_column :patrollings, :patrolling_name, :string
  end
end
