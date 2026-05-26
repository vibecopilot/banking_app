class CreateTransportRequests < ActiveRecord::Migration[5.1]
  def change
    create_table :transport_requests do |t|
      t.string :employee_name
      t.integer :employee_id
      t.string :pickup_location
      t.datetime :date_and_time
      t.text :special_requirements
      t.text :driver_contact_information
      t.text :vehicle_details
      t.integer :booking_confirmation_number
      t.string :booking_status
      t.boolean :manager_approval
      t.string :booking_confirmation_email

      t.timestamps
    end
  end
end
