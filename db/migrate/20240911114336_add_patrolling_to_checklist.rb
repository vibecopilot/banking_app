class AddPatrollingToChecklist < ActiveRecord::Migration[5.1]
  def change
    add_column :checklists, :patrolling_id, :integer
  end
end
