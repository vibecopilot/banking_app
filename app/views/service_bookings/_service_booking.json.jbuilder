json.extract! service_booking, :id, :booking_date, :status, :special_instructions,
              :total_amount, :discount_amount, :tax_amount, :final_amount,
              :payment_status, :payment_method, :transaction_id,
              :service_started_at, :service_completed_at,
              :rating, :feedback, :user_id, :unit_id,
              :service_subcategory_id, :service_slot_id, :service_pricing_id

json.unit_name service_booking&.unit&.name
json.user_name service_booking&.user.try(:full_name)
json.service_slot do
  slot = service_booking&.service_slot
  if slot
    json.id slot.id
    json.start_time slot.start_time
    json.end_time slot.end_time
  end
end

# json.akshay service_booking&.service_pricing

json.service_pricing do
	price = service_booking&.service_pricing
	if price
		json.id price.id
		json.price price.price
		json.discount_percentage price.discount_percentage
		json.tax_percentage price.tax_percentage
		json.discount_amount price.discount_amount
		json.tax_amount price.tax_amount
		json.final_price price.final_price
	end	
end

json.subcategory_name service_booking&.service_subcategory&.name
json.slot_time "#{service_booking&.service_slot&.start_time} - #{service_booking&.service_slot&.end_time}"
