json.extract! mail_room_outbound, :id, :vendor_id, :sending_date, :sender_id, :recipient_name, :mobile_number, :awb_number, :recipient_email_id, :recipient_address_1, :recipient_address_2, :state, :city, :pincode, :entity, :status,:mark_as_collected,:mail_outbound_type,:unit, :created_by_id, :collect_by_id,:recieved_by_id,:company,:company_address_1,:company_address_2,:created_at, :updated_at
json.url mail_room_outbound_url(mail_room_outbound, format: :json)
json.vendor_name Vendor.find_by(id: mail_room_outbound.vendor_id)&.vendor_name
json.recieved_by User.find_by(id: mail_room_outbound.recieved_by_id)&.full_name
json.collect_by User.find_by(id: mail_room_outbound.collect_by_id)&.full_name
json.created_by User.find_by(id: mail_room_outbound.created_by_id)&.full_name
