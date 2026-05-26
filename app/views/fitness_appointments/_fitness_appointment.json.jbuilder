json.extract! fitness_appointment, :id, :booking_type, :name, :relationship, :age, :gender, :marital_status, :date, :modile_number, :preference, :trainer, :reason_for_appointment, :created_by_id, :created_at, :updated_at
json.url fitness_appointment_url(fitness_appointment, format: :json)
