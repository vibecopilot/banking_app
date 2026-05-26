class CreateFitnessAppointments < ActiveRecord::Migration[5.1]
  def change
    create_table :fitness_appointments do |t|
      t.string :booking_type
      t.string :name
      t.string :relationship
      t.integer :age
      t.string :gender
      t.string :marital_status
      t.date :date
      t.string :modile_number
      t.string :preference
      t.integer :trainer
      t.text :reason_for_appointment

      t.timestamps
    end
  end
end
