class AddColumnsssToPatrollingHistory < ActiveRecord::Migration[5.1]
  def change
    add_column :patrolling_histories, :comment, :text
  end
end
