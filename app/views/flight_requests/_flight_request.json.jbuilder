json.extract! flight_request, :id, :employee_name, :employee_id, :departure_city, :arrival_city, :departure_date, :return_date, :preferred_airlines, :flight_class, :passenger_name, :passport_information, :ticket_confirmation_number, :booking_status, :manager_approval, :booking_confirmation_email, :created_at, :updated_at,:mobile_no,:email
json.url flight_request_url(flight_request, format: :json)

# Add additional passengers
json.additional_passengers flight_request.additional_passengers.map { |passenger|
  {
    id: passenger.id,
    name: passenger.name,
    class_type: passenger.class_type,
    gender: passenger.gender,
    created_at: passenger.created_at,
    updated_at: passenger.updated_at
  }
}
