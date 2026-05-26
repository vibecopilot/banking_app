class CreateFlightRequests < ActiveRecord::Migration[5.1]
  def change
    create_table :flight_requests do |t|
      t.string :employee_name
      t.integer :employee_id
      t.string :departure_city
      t.string :arrival_city
      t.date :departure_date
      t.date :return_date
      t.string :preferred_airlines
      t.string :flight_class
      t.string :passenger_name
      t.string :passport_information
      t.integer :ticket_confirmation_number
      t.string :booking_status
      t.boolean :manager_approval
      t.string :booking_confirmation_email

      t.timestamps
    end
  end
end
