class CreatePatrollingHistories < ActiveRecord::Migration[5.1]
  def change
    create_table :patrolling_histories do |t|
      t.integer :user_id
      t.integer :patrolling_id
      t.datetime :expected_time
      t.datetime :actual_time

      t.timestamps
    end
  end
end
