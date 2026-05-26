json.extract! amenity_booking_rule, :id, :enumerator, :duration, :level, :active, :amenity_id, :site_id, :facility_can_be_booked, :times_per_day, :period_type, :created_at, :updated_at
json.url amenity_booking_rule_url(amenity_booking_rule, format: :json)


json.prime_time do
	json.array! amenity_booking_rule.prime_times do |pt|
		json.id pt.id
		json.start_time pt.start_time
		json.end_time pt.end_time
	end
end