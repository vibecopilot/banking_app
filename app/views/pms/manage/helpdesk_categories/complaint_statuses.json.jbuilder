# app/views/manage/helpdesk_categories/complaint_statuses.json.jbuilder

if @complaint_status
  json.id @complaint_status.id
  json.society_id @complaint_status.society_id
  json.name @complaint_status.name
  json.color_code @complaint_status.color_code
  json.fixed_state @complaint_status.fixed_state
  json.active @complaint_status.active
  json.created_at @complaint_status.created_at
  json.updated_at @complaint_status.updated_at
  json.position @complaint_status.position
  json.of_phase @complaint_status.of_phase
  json.of_atype @complaint_status.of_atype
else
  @complaint_statuses.each do |status|
    json.set! "status_#{status.id}" do
      json.id status.id
      json.society_id status.society_id
      json.name status.name
      json.color_code status.color_code
      json.fixed_state status.fixed_state
      json.active status.active
      json.created_at status.created_at
      json.updated_at status.updated_at
      json.position status.position
      json.of_phase status.of_phase
      json.of_atype status.of_atype
    end
  end
end