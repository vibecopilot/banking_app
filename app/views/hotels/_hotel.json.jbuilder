json.extract! hotel, :id, :hotel_name, :location, :employee_id, :employee_name, :destination, :number_of_rooms,:email,:mobile_no,
	:room_type, :special_requests, :hotel_preferences, :check_in_date, :check_out_date, :booking_confirmation_number,
	:booking_certification_email, :booking_status, :manager_approval, :is_available, :site_id, :created_at, :updated_at
json.url hotel_url(hotel, format: :json)
