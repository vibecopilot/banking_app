class AddPatrollingToActivity < ActiveRecord::Migration[5.1]
  def change
    add_column :activities, :patrolling_id, :integer
  end
end
