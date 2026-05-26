json.extract! incident_injury, :id, :injury_type, :injury_number, :incident_id, :lost_time, :who_got_injured_id, :who_got_injured, :name, :company_name, :mobile, :created_at, :updated_at
json.url incident_injury_url(incident_injury, format: :json)
