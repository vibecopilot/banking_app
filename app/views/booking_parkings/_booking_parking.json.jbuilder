json.extract! booking_parking,
  :id, :parking_id, :booking_date, :booking_start_time,
  :booking_end_time, :user_id, :site_id, :created_by_id,
  :status, :created_at, :updated_at, :slot_id

json.user_name booking_parking.user&.full_name
json.created_by booking_parking.created_by&.full_name

parking = booking_parking.parking_configuration
json.parking_name parking&.name
json.vehicle_type parking&.vehicle_type
json.building_name parking&.building&.name
json.floor_name parking&.floor&.name

json.two_wheeler_count @two_wheeler_vacant_count || 0
json.four_wheeler_count @four_wheeler_vacant_count || 0
json.total_allotted_slots @total_allotted_slots || 0
json.total_vacant_slots @total_vacant_slots || 0

json.url booking_parking_url(booking_parking, format: :json)

json.partial! "parking_slots/parking_slot",
              parking_slot: booking_parking.parking_slot if booking_parking.parking_slot.present?
