class AddPatrollingToSubmission < ActiveRecord::Migration[5.1]
  def change
    add_column :submissions, :patrolling_id, :integer
  end
end
