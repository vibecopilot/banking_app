# json.partial! "site_assets/site_asset", site_asset: @site_asset
site_asset = @site_asset
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
@purchase_invoices = site_asset.purchase_invoices
json.purchase_invoices do
	json.array!(@purchase_invoices) do |doc|
		json.extract! doc, :id, :relation, :relation_id
		json.document doc.document_url
	end
end

@insurances = site_asset.insurances
json.insurances do
	json.array!(@insurances) do |doc|
		json.extract! doc, :id, :relation, :relation_id
		json.document doc.document_url
	end
end

@manuals = site_asset.manuals
json.manuals do
	json.array!(@manuals) do |doc|
		json.extract! doc, :id, :relation, :relation_id
		json.document doc.document_url
	end
end

@other_files = site_asset.other_files
json.other_files do
	json.array!(@other_files) do |doc|
		json.extract! doc, :id, :relation, :relation_id
		json.document doc.document_url
	end
end

json.tickets do
	if site_asset.tickets.present?
		json.array! site_asset.tickets do |ticket|
			json.extract! ticket, :id, :id_society, :ticket_number, :id_user, :asset_id, :service_id, :priority, :heading, :text, :active, :action, :IsDelete, :flat_number, :created_at, :updated_at, :issue_type_id, :is_urgent,:dept_id,:unit_id
			json.issue_status ticket&.complaint_status
		end
	end
end

json.asset_params do
	json.array! site_asset.asset_params, partial: "asset_params/asset_param", as: :asset_param
end

json.asset_amcs do
	json.array! site_asset.asset_amcs do |amc|
		json.partial! "asset_amcs/asset_amc", asset_amc: amc
	end
end
# q[checklist_ctype_eq]=ppm

json.ppm_activities do
  ppm_activities = site_asset.activities
                     .joins(:checklist)
                     .where(checklists: { ctype: 'ppm' })

  stats = @ppm_stats || {}

  json.total_count stats[:total].to_i
  json.complete_count stats[:complete].to_i
  json.overdue_count stats[:overdue].to_i
  json.upcoming_count stats[:upcoming].to_i
  json.pending_count stats[:pending].to_i
  json.scheduled_count stats[:scheduled].to_i

  percentage =
    if stats[:total].to_i > 0
      ((stats[:complete].to_f / stats[:total].to_f) * 100).round(2)
    else
      0
    end

  json.completed_percentage percentage

  json.activities do
    json.total_count   @ppm_activities.total_count
    json.current_page  @ppm_activities.current_page
    json.total_pages   @ppm_activities.total_pages

    json.records do
      json.array! @ppm_activities do |activity|
        json.partial! 'activities/activity', activity: activity
      end
    end
  end
end

	json.todays_ppm do
		json.array! @todays_ppm do |activity|
			json.partial! 'activities/activity', activity: activity
		end
	end

	json.complete_ppm do
		json.total_page @complete_ppm.total_count
		json.total_pages @complete_ppm.total_pages
		json.current_page @complete_ppm.current_page
		json.records do
			json.array! @complete_ppm do |complete|
				json.partial! 'activities/activity', activity: complete
			end
		end
	end

	json.overdue_ppm do
		json.total_page @overdue_ppm.total_count
		json.total_pages @overdue_ppm.total_pages
		json.current_page @overdue_ppm.current_page
		json.records do
			json.array! @overdue_ppm do |overdue|
				json.partial! 'activities/activity', activity: overdue
			end
		end
	end

	json.upcoming_ppm do
		json.total_page @upcoming_ppm.total_count
		json.total_pages @upcoming_ppm.total_pages
		json.current_page @upcoming_ppm.current_page
		json.records do
			json.array! @upcoming_ppm do |upcoming|
				json.partial! 'activities/activity', activity: upcoming
			end
		end
	end

	json.pending_ppm do
		json.total_page @pending_ppm.total_count
		json.total_pages @pending_ppm.total_pages
		json.current_page @pending_ppm.current_page
		json.records do
			json.array! @pending_ppm do |pending|
				json.partial! 'activities/activity', activity: pending
			end
		end
	end

	json.scheduled_ppm do
  json.total_count @scheduled_ppm.total_count
  json.current_page @scheduled_ppm.current_page
  json.total_pages @scheduled_ppm.total_pages
  json.records do
    json.array! @scheduled_ppm do |activity|
      json.partial! 'activities/activity', activity: activity
    end
  end
end

if site_asset.parent_asset.present?
	json.parent_asset do
		json.extract! site_asset.parent_asset, :id, :name
	end
end

json.asset_lifecycle do
	lifecycle_events = []
	if site_asset.created_at.present?
		lifecycle_events << { stage: 'Installed', date: site_asset.created_at.to_date, completed: true }
	end
	if site_asset.unit_id.present? || site_asset.user_id.present?
		assigned_date = site_asset.updated_at.to_date
		lifecycle_events << { stage: 'Assigned', date: assigned_date, completed: true }
	end
	if site_asset.active && !site_asset.breakdown
		in_use_date = site_asset.installation || site_asset.updated_at.to_date
		lifecycle_events << { stage: 'In Use', date: in_use_date, completed: true }
	end
	maintenance_ticket = site_asset.tickets.order(created_at: :desc).first
	if maintenance_ticket.present?
		lifecycle_events << { stage: 'Request Maint.', date: maintenance_ticket.created_at.to_date, completed: true }
	end
	under_maint_activity = site_asset.activities.where(status: 'open').order(start_time: :desc).first
	if under_maint_activity.present?
		lifecycle_events << { stage: 'Under Maint.', date: under_maint_activity.start_time&.to_date, completed: true }
	end
	completed_activity = site_asset.activities.where(status: 'complete').order(updated_at: :desc).first
	if completed_activity.present?
		lifecycle_events << { stage: 'Complete Maint.', date: completed_activity.updated_at.to_date, completed: true }
	end
	if completed_activity.present? && !site_asset.breakdown
		lifecycle_events << { stage: 'Back to Service', date: completed_activity.updated_at.to_date, completed: true }
	end
	json.array! lifecycle_events do |event|
  json.stage event[:stage]
  json.date event[:date]&.strftime('%d/%m/%Y')
  json.completed event[:completed] || false
  json.current event[:current] || false
end
end
