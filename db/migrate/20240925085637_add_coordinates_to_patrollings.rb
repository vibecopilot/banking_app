class AddCoordinatesToPatrollings < ActiveRecord::Migration[5.1]
  def change
    add_column :patrollings, :longitude, :float
    add_column :patrollings, :latitude, :float
    add_column :patrolling_histories, :longitude, :float
    add_column :patrolling_histories, :latitude, :float
  end
end
