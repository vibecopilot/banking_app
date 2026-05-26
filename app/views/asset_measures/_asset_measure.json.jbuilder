json.extract! asset_measure, :id, :asset_id, :name, :min_value, :max_value, :alert_below, :alert_above, :active, :unit_type, :multiplier_factor, :meter_tag, :meter_unit_id, :cloned, :check_previous_reading, :created_at, :updated_at
json.url asset_measure_url(asset_measure, format: :json)
