json.extract! parking_policy, :id, :who_can_park, :max_vechille_per_flat, :allowed_vehicle_type, :type_of, :payment_type, :billing_frequency, :ev_charging_available, :charging_type, :ev_charge_location, :ev_charge_fee, :who_Can_access, :visitor_parking_allowed, :terms_and_condition, :created_at, :updated_at
json.url parking_policy_url(parking_policy, format: :json)
