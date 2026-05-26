json.extract! osr_log, :id, :comment, :priority, :rating, :current_status, :created_at
json.log_by do osr_log.user.try(:full_name) end
json.status do osr_log.booking.try(:show_status) || "" end
json.staff do osr_log.society_staff.present? ? osr_log.society_staff.try(:full_name) : "" end
json.r_image do osr_log.user_id.present? ? "http://d3sinv4akkwgwk.cloudfront.net" + osr_log.user.try(:avatar).try(:url) : " " end
json.r_flat  do osr_log.user_society_id.present? ? "#{osr_log.user_society.user_flat.try(:block)}-#{osr_log.user_society.user_flat.try(:flat)}" : "" end
