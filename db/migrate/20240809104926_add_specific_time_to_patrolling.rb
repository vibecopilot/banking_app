class AddSpecificTimeToPatrolling < ActiveRecord::Migration[5.1]
  def change
    add_column :patrollings, :specific_times , :string
  end
end
