json.extract! parking_configuration, :id, :name, :building_id, :floor_id, :vehicle_type, :site_id, :created_at, :updated_at , :zone_type ,:no_of_parking_allowed ,:parking_mechanism, :no_of_levels,:no_of_units,:platform_type,:stack_type,:access_mode,:slot_per_stack,:platform_type,:maintenance_freq
json.building_name parking_configuration.building&.name
json.floor_name parking_configuration.floor&.name
json.site_name parking_configuration&.site&.name
json.url parking_configuration_url(parking_configuration, format: :json)
