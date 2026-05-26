json.extract! meter_reading, :id, :meter_id, :opening, :closing, :consumption, :parameter, :created_at, :updated_at
json.url meter_reading_url(meter_reading, format: :json)
