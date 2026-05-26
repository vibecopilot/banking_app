json.extract! qr_verification, :id, :code, :expected_time, :valid_till, :checked_in, :checked_in_at, :checked_out, :checked_out_at, :site_id, :purpose, :notes, :created_at, :updated_at

json.status qr_verification.status
json.valid_for_checkin qr_verification.valid_for_checkin?
json.time_remaining qr_verification.time_remaining
json.qr_data qr_verification.qr_data

json.generated_by do
  if qr_verification.generated_by
    json.id qr_verification.generated_by.id
    json.name qr_verification.generated_by.full_name
  end
end

json.checked_in_by do
  if qr_verification.checked_in_by
    json.id qr_verification.checked_in_by.id
    json.name qr_verification.checked_in_by.full_name
  end
end

json.checked_out_by do
  if qr_verification.checked_out_by
    json.id qr_verification.checked_out_by.id
    json.name qr_verification.checked_out_by.full_name
  end
end

json.qr_image_url qr_verification.qr_image.document_url if qr_verification.qr_image.present?

# json.url qr_verification_url(qr_verification, format: :json)
