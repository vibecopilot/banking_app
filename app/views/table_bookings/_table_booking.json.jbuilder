json.extract! table_booking, :id, :restaurant_id, :ondate, :ontime, :user_id,
              :no_of_person, :status, :restaurant_table_id,
              :contact_number, :customer_name, :notes, :created_at, :updated_at
json.created_by table_booking.created_by&.full_name
json.restaurant_name table_booking.food_and_beverage&.restaurant_name
json.restaurant_table table_booking.restaurant_table
json.url table_booking_url(table_booking, format: :json)
