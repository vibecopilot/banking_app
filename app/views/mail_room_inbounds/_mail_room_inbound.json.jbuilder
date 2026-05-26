json.extract! mail_room_inbound, :id, :vendor_id, :receiving_date, :sender, :mobile_number, :awb_number, :entity , :mark_as_collected, :company, :company_address_1, :company_address_2, :state, :city, :pincode, :mail_inbound_type, :receipant_name,:unit, :department_id,:status,:aging,:collect_on,:collect_by_id , :created_by_id, :created_at, :updated_at
json.url mail_room_inbound_url(mail_room_inbound, format: :json)
json.vendor_name Vendor.find_by(id: mail_room_inbound.vendor_id)&.vendor_name
json.department_name Department.find_by(id: mail_room_inbound.department_id)&.department_name
json.collect_by User.find_by(id: mail_room_inbound.collect_by_id)&.full_name
json.created_by User.find_by(id: mail_room_inbound.created_by_id)&.full_name
