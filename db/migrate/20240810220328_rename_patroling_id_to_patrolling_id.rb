class RenamePatrolingIdToPatrollingId < ActiveRecord::Migration[5.1]
  def change
    rename_column :patrolling_histories, :patrolling_id, :patrolling_id
  end
end
