class AddColumnToFitnessAppointments < ActiveRecord::Migration[5.1]
  def change
    add_column :fitness_appointments, :created_by_id, :integer
  end
end
