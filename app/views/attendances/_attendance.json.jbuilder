json.extract! attendance, :id, :attendance_of_id, :attendance_of_type, :resource_id, :resource_type, :punched_in_at, :punched_out_at, :work_log, :created_at, :updated_at
json.attendance_of_name attendance.attendance_of.try(:full_name)
json.staff_name attendance.staff.try(:full_name)
json.staff_number attendance.staff&.mobile_no
json.staff_work_type attendance.staff&.work_type

# Staff Profile 
json.profice_pic attendance.staff&.profile_picture&.document_url