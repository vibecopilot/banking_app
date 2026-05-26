if amenity.present?
json.extract! amenity, :id, :site_id, :fac_type, 
:is_member_adult,
:is_member_child,
:is_guest_adult,
:is_guest_child,
:is_tenant_child,
:is_tenant_adult, :fac_name, :type_of_facility, :member_charges, :tenant, :book_before, :cancel_before, :advance_booking,
              :disclaimer, :cancellation_policy, :cutoff_min, :return_percentage, :create_by, 
              :active, :member, :member_price_adult, :fixed_amount, :is_fixed, :member_price_child, :guest, 
              :guest_price_adult, :guest_price_child, :min_people, :max_people, :non_member, :non_member_price_adult, :non_member_price_child, :complimentary, :postpaid, :prepaid, :gst, :consecutive_slot_allowed,
              :terms, :deposit, :description, :max_slots, :created_at, :updated_at, :gst_no, :pay_on_facility, :sgst, :tenant_price_child, :tenant_price_adult, :status, :is_hotel, :no_of_days, :break_time_start, :break_time_end, :concurrent_slot, :slot_by, :wrap_time
json.book_before Amenity.convert_to_days_hours_and_minutes(amenity.book_before )
json.cancel_before Amenity.convert_to_days_hours_and_minutes(amenity.cancel_before )
json.advance_booking Amenity.convert_to_days_hours_and_minutes(amenity.advance_booking )
json.max_bookings_per_week amenity.setup&.max_bookings_per_week
json.bookings_this_week amenity.bookings_this_week
json.bookings_remaining_this_week amenity.bookings_remaining_this_week
json.can_book_this_week amenity.can_book_this_week?
json.url amenity_url(amenity, format: :json)



  # Include Amenity Slots
  json.amenity_slots do
    json.array! amenity.amenity_slots do |amenity_slot|
      json.partial! "amenity_slots/amenity_slot", amenity_slot: amenity_slot
    end
  end

  json.amenity_rules do
    json.array! amenity.amenity_booking_rules do |rules|
      json.partial! "amenity_booking_rules/amenity_booking_rule", amenity_booking_rule: rules
    end
  end

  json.operational_days do
    json.array! amenity.amenity_operational_days do  |op_day|
      json.id op_day.id
      json.day_of_week op_day.day_of_week
      json.start_time op_day.start_time
      json.end_time op_day.end_time
      json.is_active op_day.is_active
    end
  end


# Attachments for attach images
@attch_images = amenity&.attachments
json.attachments do
  json.array! @attch_images do |image|
    json.extract! image, :id, :relation, :relation_id
    json.image_url image.document_url
  end
end

# Attachments for cover images
@cover_images = amenity&.cover_images
json.covers do
  json.array! @cover_images do |image|
    json.extract! image, :id, :relation, :relation_id
    json.image_url image.document_url
  end
end

else
  json.error "Amenity not found"
end

