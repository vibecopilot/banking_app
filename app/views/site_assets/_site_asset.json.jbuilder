json.extract! site_asset, :id, :site_id, :building_id, :floor_id, :unit_id, :name, :serial_number, :model_number, :purchased_on, :purchase_cost, :warranty_expiry, :user_id, :critical, :breakdown, :is_meter, :parent_asset_id, :active, :created_at, :updated_at, :description, :oem_name, :capacity, :installation, :warranty_start, :remarks, :vendor_id, :asset_group_id, :uom, :asset_type, :longitude, :latitude, :comprehensive
json.building_name site_asset.building&.name
json.floor_name site_asset.floor&.name
json.unit_name site_asset.unit&.name
json.vendor_name site_asset.vendor&.vendor_name
json.group_name site_asset.asset_group&.name
json.group_id site_asset.asset_group&.id
json.sub_group_name site_asset.sub_group&.name
json.sub_group_id site_asset.sub_group&.id
json.equipemnt_id site_asset&.equipemnt_id
json.asset_number site_asset&.asset_number

json.qr_code_image_url site_asset.qr_code_image.try(:document_url)
json.url site_asset_url(site_asset, format: :json)
#@purchase_invoices = Attachfile.where("relation = 'AssetPurchaseInvoice' and relation_id = ?", site_asset.id)
@purchase_invoices = site_asset.purchase_invoices
json.purchase_invoices do
  json.array!(@purchase_invoices) do |doc|
    json.extract! doc, :id, :relation, :relation_id
    json.document doc.document_url
  end
end

# @insurances = Attachfile.where("relation = 'AssetInsurance' and relation_id = ?", site_asset.id)
@insurances = site_asset.insurances
json.insurances do
  json.array!(@insurances) do |doc|
    json.extract! doc, :id, :relation, :relation_id
    json.document doc.document_url
  end
end

# @manuals = Attachfile.where("relation = 'AssetManual' and relation_id = ?", site_asset.id)
@manuals = site_asset.manuals
json.manuals do
  json.array!(@manuals) do |doc|
    json.extract! doc, :id, :relation, :relation_id
    json.document doc.document_url
  end
end

# @other_files = Attachfile.where("relation = 'AssetOther' and relation_id = ?", site_asset.id)
@other_files = site_asset.other_files
json.other_files do
  json.array!(@other_files) do |doc|
    json.extract! doc, :id, :relation, :relation_id
    json.document doc.document_url
  end
end

# json.tickets do
#  if site_asset.tickets.present?
#   json.array! site_asset.tickets do |ticket|
#     json.extract! ticket, :id, :id_society, :ticket_number, :id_user, :asset_id, :service_id, :priority, :heading, :text, :active, :action, :IsDelete, :flat_number, :created_at, :updated_at, :issue_type_id, :is_urgent,:dept_id,:unit_id
#     json.issue_status ticket&.complaint_status
#   end
#  end
# end

# q[checklist_ctype_eq]=ppm

# json.ppm_activities do
#   ppm_activities = site_asset.activities
#                              .joins(:checklist)
#                              .where(checklists: { ctype: 'ppm' })
#   now = Time.zone.now                          
#   today_range = Time.zone.now.all_day
#   total_count = ppm_activities.count
#   completed_count = ppm_activities.where(status: 'complete').count
#   json.total_count     total_count
#   json.completed_count completed_count
#   json.pending_count   ppm_activities.where(status: 'overdue').count
#   json.upcoming_count  ppm_activities.where(status: 'upcoming').count

#   and_json_avg = (completed_count.to_f / total_count) * 100 
#   json.completed_percentage(total_count.positive? ? (and_json_avg).round(2) : 0)

#   json.activities do
#     json.array! ppm_activities do |activity|
#       json.partial! 'activities/activity', activity: activity
#     end
#   end
#   ppm_activities.where(start_time: today_range) if present?
#   json.todays_ppm do
#     json.array! ppm_activities.where(start_time: today_range) do |today|
#       json.partial! 'activities/activity', activity: activity
#     end
#   end

#   json.upcoming_ppm do
#     json.array! ppm_activities.where('start_time > ?', now) do |activity|
#       json.partial! 'activities/activity', activity: activity
#     end
#   end
# end


# if site_asset.parent_asset.present?
#   json.parent_asset do
#     json.extract! site_asset.parent_asset, :id, :name
#   end
# end


json.asset_params do
	json.array! site_asset.asset_params, partial: "asset_params/asset_param", as: :asset_param
end


#json.category @site_asset.category
#json.category_data @site_asset.category_data
#json.custom_sections @site_asset.custom_sections

# json.asset_lifecycle do
#   lifecycle_events = []
#   if site_asset.created_at.present?
#     lifecycle_events << { stage: 'Installed', date: site_asset.created_at.to_date, completed: true }
#   end
#   if site_asset.unit_id.present? || site_asset.user_id.present?
#     assigned_date = site_asset.updated_at.to_date
#     lifecycle_events << { stage: 'Assigned', date: assigned_date, completed: true }
#   end
#   if site_asset.active && !site_asset.breakdown
#     in_use_date = site_asset.installation || site_asset.updated_at.to_date
#     lifecycle_events << { stage: 'In Use', date: in_use_date, completed: true }
#   end
#   maintenance_ticket = site_asset.tickets.order(created_at: :desc).first
#   if maintenance_ticket.present?
#     lifecycle_events << { stage: 'Request Maint.', date: maintenance_ticket.created_at.to_date, completed: true }
#   end
#   under_maint_activity = site_asset.activities.where(status: 'open').order(start_time: :desc).first
#   if under_maint_activity.present?
#     lifecycle_events << { stage: 'Under Maint.', date: under_maint_activity.start_time&.to_date, completed: true }
#   end
#   completed_activity = site_asset.activities.where(status: 'complete').order(updated_at: :desc).first
#   if completed_activity.present?
#     lifecycle_events << { stage: 'Complete Maint.', date: completed_activity.updated_at.to_date, completed: true }
#   end
#   if completed_activity.present? && !site_asset.breakdown
#     lifecycle_events << { stage: 'Back to Service', date: completed_activity.updated_at.to_date, completed: true }
#   end
#   json.array! lifecycle_events do |event|
#     json.stage event[:stage]
#     json.date event[:date]&.strftime('%d/%m/%Y')
#     json.completed event[:completed] || false
#     json.current event[:current] || false
#   end
# end
