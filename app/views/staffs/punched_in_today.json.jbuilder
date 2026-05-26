json.current_page @staffs.current_page
json.total_pages @staffs.total_pages
json.total_count @staffs.total_entries

json.staffs do
  json.array! @staffs do |staff|
    json.extract! staff, :id, :site_id, :firstname, :lastname, :status_type, :created_by_id, :email, :mobile_no, :staff_id, :unit_id, :work_type, :vendor_id, :valid_from, :valid_till, :longitude, :latitude, :status, :created_at, :updated_at
    
    json.full_name staff.full_name
    json.unit_name staff.units.map(&:name).join(', ')
    json.units staff.units do |unit|
      json.id unit.id
      json.name unit.name
    end

    json.building_name staff.units.map { |a| a.building&.name }.join(', ')
    json.floor_name staff.units.map { |a| a.floor&.name }.join(', ')
    json.vendor_name staff.vendor&.vendor_name
    
    # Get today's attendance (punched in but not out)
    today_attendance = staff.attendances.where('DATE(punched_in_at) = ? AND punched_out_at IS NULL', Date.current).first
    
    if today_attendance.present?
      json.today_attendance do
        json.extract! today_attendance, :id, :punched_in_at, :punched_out_at
        json.punched_in_time today_attendance.punched_in_time
        json.formatted_date today_attendance.formatted_date
        json.formatted_day today_attendance.formatted_day
        json.duration today_attendance.duration
        json.status "Punched In"
      end
    else
      json.today_attendance nil
    end


json.working_schedule do
  if staff.working_schedule.is_a?(Hash) && staff.working_schedule.values.any? { |v| v['selected'] }
    Date::DAYNAMES.each do |day|
      schedule = staff.working_schedule[day]
      if schedule.is_a?(Hash) && schedule['selected'] && schedule['start_time'].present? && schedule['end_time'].present?
        json.set! day do
          json.start_time Time.parse(schedule['start_time']).strftime("%-I:%M %p") if schedule['start_time'].present?
          json.end_time Time.parse(schedule['end_time']).strftime("%-I:%M %p") if schedule['end_time'].present?
        end
      end
    end
  end
end

if staff.attendances.present?
  json.attendances staff.attendances, partial: "attendances/attendance", as: :attendance
else
  json.attendances {}
end

if staff.profile_picture.present?
  json.profile_picture do
    json.extract! staff.profile_picture, :id, :relation, :relation_id
    json.id staff.profile_picture.id
    json.url staff.profile_picture.image.url
    # json.file_name staff.profile_pic.image_file_name
    # json.content_type staff.profile_pic.image_content_type
    # json.file_size staff.profile_pic.image_file_size
    json.updated_at staff.profile_picture.image_updated_at
  end
else
  json.profile_picture nil
end

@attachments = Attachfile.where("relation = 'StaffDocument' and relation_id = ?", staff.id)
json.staff_documents do
  json.array!(@attachments) do |doc|
    json.extract! doc, :id, :relation, :relation_id
    json.document doc.document_url
  end
end
json.qr_code_image_url staff.qr_code_image.try(:document_url)
json.url staff_url(staff, format: :json)
  end
end
