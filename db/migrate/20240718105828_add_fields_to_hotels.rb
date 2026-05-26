class AddFieldsToHotels < ActiveRecord::Migration[5.1]
  def change
    rename_column :hotels, :start_time, :check_in_date 
    rename_column :hotels, :end_time, :check_out_date
    add_column :hotels, :employee_id, :integer
    add_column :hotels, :employee_name, :string
    add_column :hotels, :destination, :string
    add_column :hotels, :number_of_rooms, :integer
    add_column :hotels, :room_type, :string
    add_column :hotels, :special_requests, :string
    add_column :hotels, :hotel_preferences, :string
    add_column :hotels, :booking_confirmation_number, :string
    add_column :hotels, :booking_status, :string
    add_column :hotels, :manager_approval, :boolean
    add_column :hotels, :booking_certification_email, :string
  end
end
