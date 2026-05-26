class Api::V1::GroupedDashboardController < ApplicationController
  include UserExt
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_filters, except: [:org_associates]

  def index
    render json: {
      ticket_sla_health:      ticket_sla_health_data,
      ppm_compliance:         ppm_compliance_data,
      asset_health:           asset_health_data,
      workforce_availability: workforce_availability_data,
      vendor_sla:             vendor_sla_data,
      compliance_score:       compliance_score_data,
      visitors_today:         visitors_today_data,
      avg_resolution_time:    avg_resolution_time_data
    }
  end
  
  def org_associates
    # binding.pry
    company_id = params[:company_id].presence || @user&.company_id
    return render json: { sites: [], categories: [], vendors: [], groups: [] } if company_id.blank?
    sites = Site.where(company_id: company_id).order(:region, :name).select(:id, :name, :region, :company_id)
    site_ids = sites.pluck(:id)

    categories = HelpdeskCategory.pms.active.where(society_id: site_ids).distinct.pluck(:id, :name).map { |id, name| { id: id, name: name } }

    vendors = Vendor.where(site_id: site_ids).where(active: true).order(:vendor_name).select(:id, :vendor_name, :site_id).map { |v| { id: v.id, name: v.vendor_name, site_id: v.site_id } }
    groups = sites.map(&:region).compact.uniq.sort.map { |r| { id: r, name: r } }
    # binding.pry

    render json: {
      sites: sites.map { |s| { id: s.id, name: s.name, region: s.region, group_id: s.region } },
      categories: categories,
      vendors: vendors,
      groups: groups
    }
  end

  def site_performance
    sites = Site.where(id: @site_ids)

    # Pre-load open-ticket status IDs once (avoids N+1 queries)
    open_status_ids = ComplaintStatus.where(fixed_state: ["open", "pending"]).pluck(:id).map(&:to_s)
    # Match by status name "Pending" (same logic as complaints_dashboard)
    pending_status_ids = ComplaintStatus.where("LOWER(name) = ?", "pending").pluck(:id).map(&:to_s)

    rows = sites.map do |site|
      # All complaints for this site (unfiltered) — used for active ticket counts
      all_site_complaints = Complaint.where(site_id: site.id)

      # Date-filtered complaints — used for SLA calculations
      site_complaints  = all_site_complaints
      site_complaints  = site_complaints.where(created_at: @date_range) if @date_range

      site_assets      = SiteAsset.where(site_id: site.id)
      site_staffs      = Staff.where(site_id: site.id)
      # Include all checklist activities (PPM + routine) for completion %
      ppm_acts         = all_checklist_activities_for([site.id])

      # SLA metrics are date-filtered (reflects selected period)
      total_complaints   = site_complaints.count
      breached_count     = site_complaints.where(resolution_breached: true).count
      within_sla_count   = site_complaints.where(resolution_breached: false, response_breached: false).count
      sla_pct            = total_complaints > 0 ? (within_sla_count.to_f / total_complaints * 100).round(1) : 0

      total_assets     = site_assets.count
      operational_assets = site_assets.where("(active = 1 OR active IS NULL) AND (breakdown = 0 OR breakdown IS NULL) AND (critical = 0 OR critical IS NULL)").count
      asset_health_pct = total_assets > 0 ? (operational_assets.to_f / total_assets * 100).round(1) : 0

      ppm_total       = ppm_acts.count
      ppm_completed   = ppm_acts.where(status: "complete").count
      ppm_pct         = ppm_total > 0 ? (ppm_completed.to_f / ppm_total * 100).round(1) : 0

      total_staffs    = site_staffs.count
      today_present   = Attendance.where(
        attendance_of_type: "Staff",
        attendance_of_id: site_staffs.pluck(:id)
      ).where(punched_in_at: Time.now.utc.beginning_of_day..Time.now.utc.end_of_day).count
      workforce_pct   = total_staffs > 0 ? (today_present.to_f / total_staffs * 100).round(1) : 0

      # Active tickets: open/pending across ALL time (not date-filtered)
      open_ticket_count = all_site_complaints.where(issue_status: open_status_ids).count
      pending_ticket_count = all_site_complaints.where(issue_status: pending_status_ids).count

      {
        id:                site.id,
        name:              site&.name,
        group:             site.region,
        city:              site.city,
        health_score:      asset_health_pct,
        sla_percentage:    sla_pct,
        ppm_percentage:    ppm_pct,
        open_tickets:      open_ticket_count,
        pending_tickets:   pending_ticket_count,
        breached_tickets:  breached_count,
        total_assets:      total_assets,
        workforce_percentage: workforce_pct
      }
    end

    render json: {
      total_sites: rows.size,
      sites:       rows
    }
  end

  # Drill-down: full associated data for a single site
  def site_drill
    site_id = params[:site_id].to_i
    return render json: { error: "site_id required" }, status: :unprocessable_entity if site_id.zero?

    allowed_ids = @site_ids.presence || Site.where(company_id: @user&.company_id).pluck(:id)
    return render json: { error: "Site not found" }, status: :not_found unless allowed_ids.include?(site_id)

    site = Site.find_by(id: site_id)
    return render json: { error: "Site not found" }, status: :not_found unless site

    # Date range for tickets/PPM (use same as filters)
    from_d = @from_date
    to_d   = @to_date

    # Blocks (commercial site: blocks instead of buildings)
    blocks = site.buildings.includes(:floors).map do |b|
      floor_count = b.floors.count
      {
        id:           b.id,
        name:         b.name,
        floor_no:     b.floor_no,
        floor_count:  floor_count,
        units_count:  b.units.count
      }
    end

    # Complaints (tickets)
    all_complaints = Complaint.where(site_id: site_id).includes(:complaint_status)
    complaints = all_complaints
    complaints = complaints.where(created_at: from_d..to_d) if from_d && to_d
    total_tickets = complaints.count
    breached = complaints.where(resolution_breached: true).count
    within_sla = complaints.where(resolution_breached: false, response_breached: false).count
    sla_pct = total_tickets > 0 ? (within_sla.to_f / total_tickets * 100).round(1) : 0
    open_ids = ComplaintStatus.where(fixed_state: ["open", "pending"]).pluck(:id).map(&:to_s)
    # Match by status name "Pending" (same logic as complaints_dashboard)
    pending_ids = ComplaintStatus.where("LOWER(name) = ?", "pending").pluck(:id).map(&:to_s)
    # Active tickets: open/pending across ALL time (not date-filtered)
    open_tickets_count = all_complaints.where(issue_status: open_ids).count
    pending_tickets_count = all_complaints.where(issue_status: pending_ids).count

    # Show only pending tickets in recent list
    recent_tickets = all_complaints.where(issue_status: pending_ids).order(created_at: :desc).limit(15).map do |c|
      {
        id:            c.id,
        ticket_number: c.ticket_number,
        heading:       c.heading,
        priority:      c.priority,
        sla_status:    c.resolution_breached ? "Breached" : (c.response_breached ? "At Risk" : "Within SLA"),
        status:        c.complaint_status&.name,
        created_at:    c.created_at,
        category:      c.category_type&.name
      }
    end

    # Assets - mutually exclusive counts (priority: offline > critical > maintenance > operational)
    assets = SiteAsset.where(site_id: site_id).includes(:building, :floor, :asset_group)
    total_assets = assets.count
    offline = assets.where(active: [false, 0]).count
    critical_count = assets.where("(active = 1 OR active IS NULL) AND critical = 1").count
    maintenance = assets.where("(active = 1 OR active IS NULL) AND (critical = 0 OR critical IS NULL) AND breakdown = 1").count
    operational = assets.where("(active = 1 OR active IS NULL) AND (breakdown = 0 OR breakdown IS NULL) AND (critical = 0 OR critical IS NULL)").count
    asset_health_pct = total_assets > 0 ? (operational.to_f / total_assets * 100).round(1) : 0

    asset_breakdown = [
      { status: "operational", count: operational },
      { status: "maintenance",  count: maintenance },
      { status: "critical",     count: critical_count },
      { status: "offline",      count: offline }
    ]

    critical_assets = assets.where(critical: true).limit(10).map do |a|
      {
        id:           a.id,
        name:         a.name,
        asset_number: a.asset_number,
        location:     [a.building&.name, a.floor&.name].compact.join(", "),
        category:     a.asset_group&.name
      }
    end

    assets_by_category = SiteAsset.where(site_id: site_id)
    .group(:name)
    .count
    .map { |name, cnt| { category: name, count: cnt } }

    # PPM (includes all checklist activities: PPM + routine)
    ppm_range = (from_d && to_d) ? (from_d..to_d) : nil
    ppm_acts = all_checklist_activities_for([site_id], ppm_range)
    ppm_total = ppm_acts.count
    ppm_completed = ppm_acts.where(status: "complete").count
    ppm_pct = ppm_total > 0 ? (ppm_completed.to_f / ppm_total * 100).round(1) : 0

    ppm_totals = ppm_acts
    .group("COALESCE(checklists.name, 'Uncategorized')")
    .count
    ppm_completed_by_cat = ppm_acts
    .where(status: "complete")
    .group("COALESCE(checklists.name, 'Uncategorized')")
    .count
    ppm_by_category = ppm_totals.keys.uniq.map do |cat|
      total = ppm_totals[cat] || 0
      completed = ppm_completed_by_cat[cat] || 0
      { category: cat, total: total, completed: completed, percentage: total > 0 ? (completed.to_f / total * 100).round(1) : 0 }
    end

    # Workforce
    staffs = Staff.where(site_id: site_id)
    total_staff = staffs.count
    staff_ids = staffs.pluck(:id)
    today_present = Attendance.where(attendance_of_type: "Staff", attendance_of_id: staff_ids).where(punched_in_at: Time.now.utc.beginning_of_day..Time.now.utc.end_of_day).count
    workforce_pct = total_staff > 0 ? (today_present.to_f / total_staff * 100).round(1) : 0

    workforce_by_vendor = staffs
    .joins("LEFT JOIN vendors ON vendors.id = staffs.vendor_id")
    .group("COALESCE(vendors.vendor_name, 'In-House')")
    .count
    .map { |vendor, cnt| { vendor: vendor, count: cnt } }

    workforce_by_type = staffs.group(:work_type).count.map { |wt, cnt| { work_type: wt || "Unspecified", count: cnt } }
    # binding.pry
    # Vendors at site
    vendors_at_site = Vendor.where(site_id: site_id).where(active: true).limit(20).map do |v|
      {
        id:    v.id,
        name:  v.vendor_name,
        expiry: v.aggremenet_end_date
      }
    end

    render json: {
      site: {
        id:     site.id,
        name:   site.name,
        region: site.region,
        active: site.active
      },
      summary: {
        health_score:        asset_health_pct,
        sla_percentage:      sla_pct,
        ppm_percentage:      ppm_pct,
        workforce_percentage: workforce_pct,
        open_tickets:        open_tickets_count,
        pending_tickets:     pending_tickets_count,
        breached_tickets:    breached,
        total_tickets:       total_tickets,
        total_assets:        total_assets,
        total_staff:         total_staff
      },
      blocks:                blocks,
      tickets: {
        summary: { total: total_tickets, open: open_tickets_count, pending: pending_tickets_count, breached: breached, sla_percentage: sla_pct },
        recent:  recent_tickets
      },
      assets: {
        summary: { total: total_assets, operational: operational, maintenance: maintenance, critical: critical_count, offline: offline, health_percentage: asset_health_pct },
        breakdown: asset_breakdown,
        by_category: assets_by_category,
        critical_assets: critical_assets
      },
      ppm: {
        total:     ppm_total,
        completed: ppm_completed,
        percentage: ppm_pct,
        by_category: ppm_by_category
      },
      workforce: {
        total:    total_staff,
        present:  today_present,
        percentage: workforce_pct,
        by_vendor: workforce_by_vendor,
        by_work_type: workforce_by_type
      },
      vendors: vendors_at_site
    }
  end

  def asset_portfolio
    assets = SiteAsset.where(site_id: @site_ids)
    total = assets.count
    
    # Mutually exclusive status distribution (priority: offline > critical > maintenance > operational)
    offline      = assets.where(active: [false, 0]).count
    critical     = assets.where("(active = 1 OR active IS NULL) AND critical = 1").count
    maintenance  = assets.where("(active = 1 OR active IS NULL) AND (critical = 0 OR critical IS NULL) AND breakdown = 1").count
    operational  = assets.where("(active = 1 OR active IS NULL) AND (breakdown = 0 OR breakdown IS NULL) AND (critical = 0 OR critical IS NULL)").count

    # Category breakdown: aggregated by asset_group (category)
    category_data = assets
    .includes(:asset_group)
    .group_by { |a| a.asset_group&.name || "Uncategorized" }
    .map do |category_name, category_assets|
      cat_total = category_assets.size
      cat_operational = category_assets.count do |a|
        (a.active.nil? || a.active == true || a.active == 1) &&
          (a.breakdown.nil? || a.breakdown == false || a.breakdown == 0) &&
          (a.critical.nil? || a.critical == false || a.critical == 0)
      end
      {
        category:           category_name,
        total:              cat_total,
        operational:        cat_operational,
        health_percentage:  cat_total > 0 ? (cat_operational.to_f / cat_total * 100).round(1) : 0
      }
    end
    .sort_by { |c| -c[:total] }

    critical_assets = assets
    .where(critical: true)
    .includes(:building, :floor, :asset_group)
    .order(updated_at: :desc)
    .limit(10)
    .map do |a|
      {
        id:           a.id,
        name:         a.name,
        asset_number: a.asset_number,
        location:     [a.building&.name, a.floor&.name].compact.join(", "),
        category:     a.asset_group&.name,
        breakdown:    a.breakdown
      }
    end
    render json: {
      summary: {
        total:        total,
        operational:  operational,
        maintenance:  maintenance,
        critical:     critical,
        offline:      offline,
        health_percentage: total > 0 ? (operational.to_f / total * 100).round(1) : 0
      },
      category_breakdown:     category_data,
      critical_assets:        critical_assets
    }
  end

  # Drill-down: assets by status (operational|maintenance|critical|offline) or by category name
  def asset_drill
    assets = SiteAsset.where(site_id: @site_ids).includes(:building, :floor, :asset_group)

    if params[:status].present?
      case params[:status].to_s.downcase
      when "operational"
        assets = assets.where("(active = 1 OR active IS NULL) AND (breakdown = 0 OR breakdown IS NULL) AND (critical = 0 OR critical IS NULL)")
      when "maintenance"
        # Maintenance: active AND not critical AND breakdown
        assets = assets.where("(active = 1 OR active IS NULL) AND (critical = 0 OR critical IS NULL) AND breakdown = 1")
      when "critical"
        # Critical: active AND critical (regardless of breakdown)
        assets = assets.where("(active = 1 OR active IS NULL) AND critical = 1")
      when "offline"
        assets = assets.where(active: [false, 0])
      end
    end

    if params[:category].present?
      category_name = params[:category].to_s
      if category_name.downcase == "uncategorized"
        assets = assets.left_joins(:asset_group).where(asset_groups: { id: nil })
      else
        assets = assets.joins(:asset_group).where(asset_groups: { name: category_name })
      end
    end

    # Calculate summary stats for the filtered assets (mutually exclusive)
    total_count = assets.count
    offline_count = assets.where(active: [false, 0]).count
    critical_count = assets.where("(active = 1 OR active IS NULL) AND critical = 1").count
    maintenance_count = assets.where("(active = 1 OR active IS NULL) AND (critical = 0 OR critical IS NULL) AND breakdown = 1").count
    operational_count = assets.where("(active = 1 OR active IS NULL) AND (breakdown = 0 OR breakdown IS NULL) AND (critical = 0 OR critical IS NULL)").count

    records = assets.includes(:site).order(updated_at: :desc).limit(200).map do |a|
      {
        id:            a.id,
        name:          a.name,
        asset_number:  a.asset_number,
        location:      [a.building&.name, a.floor&.name].compact.join(", "),
        category:      a.asset_group&.name || "Uncategorized",
        status:        asset_status_label(a),
        breakdown:     a.breakdown,
        critical:      a.critical,
        active:        a.active,
        site_id:       a.site_id,
        site_name:     a.site&.name,
        updated_at:    a.updated_at
      }
    end

    render json: {
      drill_type:   params[:status].present? ? "status" : "category",
      filter_value: params[:status].presence || params[:category].presence,
      total:        total_count,
      summary: {
        total:       total_count,
        operational: operational_count,
        maintenance: maintenance_count,
        critical:    critical_count,
        offline:     offline_count,
        health_percentage: total_count > 0 ? (operational_count.to_f / total_count * 100).round(1) : 0
      },
      records:      records
    }
  end

  # Get activities/tasks for a specific asset
  def asset_activities
    asset_id = params[:asset_id].to_i
    return render json: { error: "asset_id required" }, status: :unprocessable_entity if asset_id.zero?

    asset = SiteAsset.find_by(id: asset_id)
    return render json: { error: "Asset not found" }, status: :not_found unless asset

    # Activities linked to this asset (via checklists)
    activities = Activity.where(asset_id: asset_id)
    .includes(:checklist)
    .order(start_time: :desc)
    activities = activities.where(start_time: @date_range) if @date_range

    total = activities.count
    completed = activities.where(status: "complete").count
    pending = activities.where(status: ["pending", nil]).count
    overdue = activities.where(status: "overdue").count
    missed = activities.where(status: "missed").count

    records = activities.limit(100).map do |a|
      {
        id:            a.id,
        checklist:     a.checklist&.name || "Uncategorized",
        checklist_type: a.checklist&.ctype,
        status:        a.status || "pending",
        start_time:    a.start_time,
        end_time:      a.end_time,
        completed_at:  a.completed_at,
        assigned_to:   a.assigned_to_id,
        notes:         a.notes
      }
    end

    render json: {
      asset: {
        id:           asset.id,
        name:         asset.name,
        asset_number: asset.asset_number,
        status:       asset_status_label(asset)
      },
      summary: {
        total:      total,
        completed:  completed,
        pending:    pending,
        overdue:    overdue,
        missed:     missed,
        completion_percentage: total > 0 ? (completed.to_f / total * 100).round(1) : 0
      },
      activities: records
    }
  end

  # Drill-down: workforce by vendor name or work_type
  # Uses same "today" range as workforce API for consistent present/absent counts
  def workforce_drill
    staffs = Staff.where(site_id: @site_ids)
    today_range = Time.now.utc.beginning_of_day..Time.now.utc.end_of_day
    today_attendances = Attendance
    .where(attendance_of_type: "Staff")
    .where(attendance_of_id: staffs.pluck(:id))
    .where(punched_in_at: today_range)

    if params[:vendor].present?
      vendor_name = params[:vendor].to_s
      if vendor_name.downcase == "in-house"
        staffs = staffs.where(vendor_id: nil)
      else
        vendor_ids = Vendor.where(site_id: @site_ids, vendor_name: vendor_name).pluck(:id)
        staffs = staffs.where(vendor_id: vendor_ids)
      end
    end

    if params[:work_type].present?
      staffs = staffs.where(work_type: params[:work_type])
    end

    staff_ids = staffs.pluck(:id)
    if params[:attendance].present?
      case params[:attendance].to_s.downcase
      when "present"
        present_ids = today_attendances.where(attendance_of_id: staff_ids).pluck(:attendance_of_id).uniq
        staffs = staffs.where(id: present_ids)
        staff_ids = staffs.pluck(:id)
      when "absent"
        present_ids = today_attendances.where(attendance_of_id: staff_ids).pluck(:attendance_of_id).uniq
        staffs = staffs.where.not(id: present_ids)
        staff_ids = staffs.pluck(:id)
      end
    end
    present_ids = today_attendances.where(attendance_of_id: staff_ids).pluck(:attendance_of_id).uniq

    records = staffs.order(:vendor_id, :work_type).limit(200).map do |s|
      present = present_ids.include?(s.id)
      full_name = [s.firstname, s.lastname].compact.join(" ").presence || "Staff ##{s.id}"
      {
        id:            s.id,
        name:          full_name,
        employee_no:   s.staff_id,
        work_type:     s.work_type || "Unspecified",
        vendor:        s.vendor&.vendor_name || "In-House",
        site_id:       s.site_id,
        site_name:     s.site&.name,
        present_today: present
      }
    end

    drill_type = if params[:vendor].present?
      "vendor"
    elsif params[:work_type].present?
      "work_type"
    else
      "attendance"
    end
    filter_value = params[:vendor].presence || params[:work_type].presence || params[:attendance].presence

    render json: {
      drill_type:   drill_type,
      filter_value: filter_value,
      total:        records.size,
      present:      records.count { |r| r[:present_today] },
      absent:       records.size - records.count { |r| r[:present_today] },
      records:      records
    }
  end

  def service_desk
    complaints = Complaint.where(site_id: @site_ids)
    complaints = complaints.where(created_at: @date_range) if @date_range
    complaints = complaints.where(category_type_id: @category_id) if @category_id.present?
    # Status counts via complaint_statuses fixed_state
    open_ids       = ComplaintStatus.where(fixed_state: "open").pluck(:id).map(&:to_s)
    pending_ids    = ComplaintStatus.where(fixed_state: "pending").pluck(:id).map(&:to_s)
    in_progress_ids = ComplaintStatus.where(fixed_state: "in_progress").pluck(:id).map(&:to_s)
    resolved_ids   = ComplaintStatus.where(fixed_state: "complete").pluck(:id).map(&:to_s)
    closed_ids     = ComplaintStatus.where(fixed_state: "closed").pluck(:id).map(&:to_s)
    total        = complaints.count
    open_count   = complaints.where(issue_status: open_ids).count
    pending_count = complaints.where(issue_status: pending_ids).count
    in_progress  = complaints.where(issue_status: in_progress_ids).count
    resolved     = complaints.where(issue_status: resolved_ids).count
    closed       = complaints.where(issue_status: closed_ids).count
    # SLA status
    breached     = complaints.where(resolution_breached: true).count
    at_risk      = complaints.where(response_breached: true, resolution_breached: false).count
    within_sla   = complaints.where(resolution_breached: false, response_breached: false).count
    sla_pct      = total > 0 ? (within_sla.to_f / total * 100).round(1) : 0
    # Tickets by category
    by_category = complaints
    .joins("LEFT JOIN helpdesk_categories ON helpdesk_categories.id = complaints.category_type_id")
    .group("helpdesk_categories.name")
    .select(
      "COALESCE(helpdesk_categories.name, 'Uncategorized') AS category_name",
      "COUNT(*) AS cnt"
    )
    .map { |r| { category: r.category_name, count: r.cnt.to_i } }
    .sort_by { |r| -r[:count] }
    # Priority tickets (breached or critical priority, open)
    priority_tickets = complaints
    .joins(:complaint_status)
    .where(resolution_breached: true)
    .or(complaints.joins(:complaint_status).where(priority: "critical"))
    .order(created_at: :desc)
    .limit(10)
    .map do |c|
      {
        id:             c.id,
        ticket_number:  c.ticket_number,
        heading:        c.heading,
        priority:       c.priority,
        sla_status:     c.resolution_breached ? "Breached" : (c.response_breached ? "At Risk" : "Within SLA"),
        status:         c.complaint_status&.name,
        created_at:     c.created_at
      }
    end

    avg_hrs = avg_resolution_hours(complaints)
    render json: {
      summary: {
        total:        total,
        open:         open_count,
        in_progress:  in_progress,
        pending:      pending_count,
        resolved:     resolved,
        closed:       closed
      },
      sla_status: {
        within_sla:        within_sla,
        at_risk:           at_risk,
        breached:          breached,
        sla_percentage:    sla_pct
      },
      tickets_by_category: by_category,
      priority_tickets:    priority_tickets,
      avg_resolution_time_hours: avg_hrs
    }
  end

  # Drill-down: PPM activities by category (checklist name) - full list
  # Uses all_checklist_activities_for to match what site_drill shows in ppm.by_category
  def ppm_drill
    ppm_acts = all_checklist_activities_for(@site_ids)
    category_name = params[:category].to_s.presence
    return render json: { error: "category required" }, status: :unprocessable_entity if category_name.blank?

    if category_name.downcase == "uncategorized"
      ppm_acts = ppm_acts.where(checklists: { name: [nil, ""] })
    else
      ppm_acts = ppm_acts.where(checklists: { name: category_name })
    end

    records = ppm_acts
    .includes(:checklist, site_asset: [:asset_group, :building, :floor, :site])
    .order(start_time: :desc)
    .limit(200)
    .map do |a|
      sa = a.site_asset
      loc = [sa&.building&.name, sa&.floor&.name].compact.join(", ")
      {
        id:            a.id,
        asset_id:      a.asset_id,
        asset_name:    sa&.name,
        asset_number:  sa&.asset_number,
        checklist:     a.checklist&.name || "Uncategorized",
        category:      sa&.asset_group&.name || "Uncategorized",
        location:      loc.presence || "—",
        status:        a.status || "pending",
        start_time:    a.start_time,
        end_time:      a.end_time,
        site_name:     sa&.site&.name
      }
    end

    total = records.size
    completed = records.count { |r| r[:status] == "complete" }
    render json: {
      drill_type:   "category",
      filter_value: category_name,
      total:        total,
      completed:    completed,
      records:      records
    }
  end

  def ppm_operations
    ppm_acts   = ppm_activities_for(@site_ids)
    soft_acts  = soft_service_activities_for(@site_ids)
    ppm_total     = ppm_acts.count
    ppm_completed = ppm_acts.where(status: "complete").count
    ppm_missed    = ppm_acts.where(status: "missed").count
    ppm_overdue   = ppm_acts.where(status: "overdue").count
    ppm_pending   = ppm_acts.where(status: ["pending", nil]).count
    ppm_pct       = ppm_total > 0 ? (ppm_completed.to_f / ppm_total * 100).round(1) : 0
    # PPM by checklist name
    ppm_by_category = ppm_acts
    .group("checklists.name")
    .select(
      "COALESCE(checklists.name, 'Uncategorized') AS group_name",
      "COUNT(*) AS total_count",
      "SUM(CASE WHEN activities.status = 'complete' THEN 1 ELSE 0 END) AS completed_count"
    )
    .map do |r|
      t = r.total_count.to_i
      c = r.completed_count.to_i
      {
        category:           r.group_name,
        total:              t,
        completed:          c,
        completion_percentage: t > 0 ? (c.to_f / t * 100).round(1) : 0
      }
    end
    # Soft services
    soft_total     = soft_acts.count
    soft_completed = soft_acts.where(status: "complete").count
    soft_pending   = soft_acts.where(status: ["pending", nil]).count
    soft_overdue   = soft_acts.where(status: "overdue").count
    soft_pct       = soft_total > 0 ? (soft_completed.to_f / soft_total * 100).round(1) : 0
    # binding.pry
    render json: {
      ppm: {
        total:                ppm_total,
        completed:            ppm_completed,
        missed:               ppm_missed,
        overdue:              ppm_overdue,
        pending:              ppm_pending,
        completion_percentage: ppm_pct,
        by_category:          ppm_by_category
      },
      soft_services: {
        total:                soft_total,
        completed:            soft_completed,
        pending:              soft_pending,
        overdue:              soft_overdue,
        completion_percentage: soft_pct
      }
    }
  end

  def workforce
    staffs        = Staff.where(site_id: @site_ids)
    staffs        = staffs.where(vendor_id: @vendor_id) if @vendor_id.present?
    total_staffs  = staffs.count
    staff_ids     = staffs.pluck(:id)

    today_attendances = Attendance
    .where(attendance_of_type: "Staff", attendance_of_id: staff_ids)
    .where(punched_in_at: Time.now.utc.beginning_of_day..Time.now.utc.end_of_day)

    present_ids   = today_attendances.pluck(:attendance_of_id).uniq
    present_count = present_ids.size
    absent_count  = total_staffs - present_count

    # By vendor breakdown
    by_vendor = staffs
    .joins("LEFT JOIN vendors ON vendors.id = staffs.vendor_id")
    .group("vendors.vendor_name, vendors.id")
    .select(
      "vendors.id AS vendor_id",
      "COALESCE(vendors.vendor_name, 'In-House') AS vendor_name",
      "COUNT(staffs.id) AS total_count"
    )
    .map do |r|
      vid = r.respond_to?(:vendor_id) ? r.vendor_id : r["vendor_id"]
      vendor_staff_ids = vid.present? ? staffs.where(vendor_id: vid).pluck(:id) : staffs.where(vendor_id: nil).pluck(:id)
      vendor_present = today_attendances.where(attendance_of_id: vendor_staff_ids).count
      {
        vendor:        r.vendor_name,
        total:         r.total_count.to_i,
        present:       vendor_present,
        absent:        r.total_count.to_i - vendor_present
      }
    end

    # Work type breakdown
    by_work_type = staffs
    .group(:work_type)
    .count
    .map { |wt, cnt| { work_type: wt || "Unspecified", count: cnt } }

    # binding.pry
    render json: {
      summary: {
        total:                  total_staffs,
        present:                present_count,
        absent:                 absent_count,
        availability_percentage: total_staffs > 0 ? (present_count.to_f / total_staffs * 100).round(1) : 0
      },
      by_vendor:    by_vendor,
      by_work_type: by_work_type
    }
  end

  def compliance
    trackers = ComplianceTracker.where(site_id: @site_ids)
    trackers = trackers.where(created_at: @date_range) if @date_range

    total           = trackers.count
    compliant       = trackers.where(status: %w[compliant complete]).count
    non_compliant   = trackers.where(status: %w[non_compliant failed]).count
    pending         = trackers.where(status: [nil, "pending", "in_progress"]).count
    score_pct       = total > 0 ? (compliant.to_f / total * 100).round(1) : 0

    # Overdue (due_date passed without completion)
    overdue = trackers.where("due_date < ? AND status NOT IN (?)", Time.now.utc.beginning_of_day..Time.now.utc.end_of_day, %w[compliant completed]).count

    # By compliance config
    by_config = trackers
    .joins("LEFT JOIN compliance_configs ON compliance_configs.id = compliance_trackers.compliance_config_id")
    .group("compliance_configs.title, compliance_configs.id")
    .select(
      "COALESCE(compliance_configs.title, 'Unknown') AS config_title",
      "COUNT(*) AS total_count",
      "SUM(CASE WHEN compliance_trackers.status IN ('compliant','complete') THEN 1 ELSE 0 END) AS compliant_count"
    )
    .map do |r|
      {
        config:    r.config_title,
        total:     r.total_count.to_i,
        compliant: r.compliant_count.to_i
      }
    end

    render json: {
      summary: {
        total:              total,
        compliant:          compliant,
        non_compliant:      non_compliant,
        pending:            pending,
        overdue:            overdue,
        compliance_score:   score_pct
      },
      by_config: by_config
    }
  end

  def visitors_detail
    visitors = Visitor.where(site_id: @site_ids).where(is_deleted: false)

    today_visits = VisitorVisit
    .joins(:visitor)
    .where(visitors: { site_id: @site_ids, is_deleted: false })
    .where(check_in: Time.now.utc.beginning_of_day..Time.now.utc.end_of_day)
    .where(is_deleted: false)

    checked_in_today  = today_visits.count
    checked_out_today = today_visits.where.not(check_out: nil).count
    currently_inside  = checked_in_today - checked_out_today

    period_visitors = @date_range ? visitors.where(created_at: @date_range) : visitors

    by_category = period_visitors
    .group("COALESCE(visitors.visit_type, 'Walk-in')")
    .count
    .map { |cat, cnt| { category: cat.to_s, count: cnt } }

    completed_visits = VisitorVisit
    .joins(:visitor)
    .where(visitors: { site_id: @site_ids, is_deleted: false })
    .where.not(check_out: nil)
    .where(is_deleted: false)
    completed_visits = completed_visits.where(check_in: @from_date.to_time.utc.beginning_of_day..@to_date.to_time.utc.end_of_day) if @from_date && @to_date

    avg_duration_minutes = if completed_visits.any?
      durations = completed_visits.pluck(:check_in, :check_out).map do |cin, cout|
        (cout - cin) / 60.0
      end
      (durations.sum / durations.size).round(1)
    else
      0
    end

    render json: {
      today: {
        checked_in:       checked_in_today,
        checked_out:      checked_out_today,
        currently_inside: currently_inside > 0 ? currently_inside : 0
      },
      period: {
        total:                period_visitors.count,
        avg_duration_minutes: avg_duration_minutes,
        by_category:          by_category
      }
    }
  end

  # Drill-down: full visitor/visit records for panel (category, check-in, host, approved, purpose, etc.)
  def visitors_drill
    scope = VisitorVisit
    .joins(:visitor)
    .where(visitors: { site_id: @site_ids, is_deleted: false })
    .where(visitor_visits: { is_deleted: false })
    .includes(visitor: [:created_by, :visitor_category, :site, { hosts: :user }])
    .order("visitor_visits.check_in DESC")
    scope = scope.where(check_in: @date_range) if @date_range

    scope = scope.where("COALESCE(visitors.visit_type, 'Walk-in') = ?", params[:category]) if params[:category].present?

    records = scope.limit(500).map do |vv|
      v = vv.visitor
      host_record = v.hosts.first
      {
        id:                vv.id,
        visitor_id:        v.id,
        visitor_name:      v.name,
        contact_no:        v.contact_no,
        purpose:           v.purpose,
        visit_type:        v.visit_type.presence || "Walk-in",
        category:          v.visitor_category&.name.presence || v.visit_type.presence || "Walk-in",
        check_in:          vv.check_in,
        check_out:         vv.check_out,
        created_at:        vv.created_at,
        visitor_created_at: v.created_at,
        created_by:        v.created_by ? [v.created_by.firstname, v.created_by.lastname].compact.join(" ").presence : nil,
        created_by_id:     v.created_by_id,
        host_name:         host_record&.user ? [host_record.user.firstname, host_record.user.lastname].compact.join(" ").presence : nil,
        host_id:           host_record&.user_id,
        approved:          host_record.nil? ? nil : (host_record.is_approved.nil? ? "pending" : (host_record.is_approved ? "approved" : "rejected")),
        site_name:         v.site&.name,
        site_id:           v.site_id,
        status:            vv.check_out.present? ? "checked_out" : "inside"
      }
    end

    today_range = Time.now.utc.beginning_of_day..Time.now.utc.end_of_day
    today_visits = scope.where(check_in: today_range)
    checked_in_today = today_visits.count
    checked_out_today = today_visits.where.not(check_out: nil).count
    currently_inside = [checked_in_today - checked_out_today, 0].max

    render json: {
      total:             records.size,
      today:             { checked_in: checked_in_today, checked_out: checked_out_today, currently_inside: currently_inside },
      filter_category:  params[:category],
      records:           records
    }
  end

  private

  # ─── Filter Setup ────────────────────────────────────────────────────────────

  def set_filters
    @user = @current_user || @user

    if params[:site_ids].present?
      @site_ids = Array(params[:site_ids]).map(&:to_i).reject(&:zero?)
    elsif params[:site_id].present?
      @site_ids = [params[:site_id].to_i].reject(&:zero?)
    elsif params[:company_id].present?
      @site_ids = Site.where(company_id: params[:company_id]).pluck(:id)
    elsif params[:role].present? && @user.present?
      @site_ids = site_ids_for_role(params[:role])
    end
    @site_ids = [@user.current_site_id] if @site_ids.blank? && @user&.current_site_id.present?
    # Fallback: use all company sites when no filters yield sites
    if @site_ids.blank? && @user.present?
      cid = @user.company_id || @user.site&.company_id
      @site_ids = Site.where(company_id: cid).pluck(:id) if cid.present?
    end

    @site_id = @site_ids&.first
    @site    = Site.find_by(id: @site_id)

    @category_id = params[:category_id].presence&.to_i
    @vendor_id   = params[:vendor_id].presence&.to_i

    @from_date = params[:from_date].present? ? Time.zone.parse(params[:from_date]).beginning_of_day : nil
    @to_date   = params[:to_date].present?   ? Time.zone.parse(params[:to_date]).end_of_day         : nil
    @date_range = (@from_date && @to_date) ? (@from_date..@to_date) : nil
  end

  def site_ids_for_role(role)
    cid = @user.company_id || @user.site&.company_id
    case role.to_s.downcase
    when "ceo"
      Site.where(company_id: cid).pluck(:id) if cid.present?
      #when "fm_head"
      #  region = @user.site&.region
      #  Site.where(company_id: cid ).pluck(:id) if cid.present?
      #when "ops"
      #  [@user.current_site_id].compact if @user.current_site_id.present?
      #end
    else
      []
    end
    # binding.pry
  end

  # ─── Metric Helpers ──────────────────────────────────────────────────────────

  def ticket_sla_health_data

    complaints = Complaint.where(site_id:@site_ids)
    complaints = complaints.where(created_at: @date_range) if @date_range

    prev = Complaint.where(site_id:@site_ids)
    prev = prev.where(created_at: prev_period_range) if @date_range

    within = complaints.where(
      resolution_breached:false,
      response_breached:false
    )

    prev_within = prev.where(
      resolution_breached:false,
      response_breached:false
    )

    at_risk = complaints.where(response_breached:true,resolution_breached:false)
    breached = complaints.where(resolution_breached:true)

    total = complaints.count
    prev_total = prev.count

    pct = total>0 ?
      (within.count.to_f/total*100).round(1):0

    prev_pct = prev_total>0 ?
      (prev_within.count.to_f/prev_total*100).round(1):0

    {
      summary:{
        percentage:pct,
        prev_percentage:prev_pct,
        vs_last_period:(pct-prev_pct).round(1),

        within_sla:within.count,
        prev_within_sla:prev_within.count,

        at_risk:complaints.where(response_breached:true,resolution_breached:false).count,
        prev_at_risk:prev.where(response_breached:true,resolution_breached:false).count,

        breached:complaints.where(resolution_breached:true).count,
        prev_breached:prev.where(resolution_breached:true).count,

        total:total,
        prev_total:prev_total
      },

      records:{
        within_sla: within.includes(:complaint_status).limit(50).order(created_at: :desc).map { |c| serialize_complaint(c) },
        at_risk:    at_risk.includes(:complaint_status).limit(50).order(created_at: :desc).map { |c| serialize_complaint(c) },
        breached:   breached.includes(:complaint_status).limit(50).order(created_at: :desc).map { |c| serialize_complaint(c) }
      }
    }

  end

  def ppm_compliance_data

    ppm_acts = ppm_activities_for(@site_ids)
    prev_ppm = ppm_activities_for(@site_ids, prev_period_range)

    total = ppm_acts.count
    prev_total = prev_ppm.count

    completed_scope = ppm_acts.where(status: "complete")
    pending_scope   = ppm_acts.where(status: ["pending", nil])
    missed_scope    = ppm_acts.where(status: "missed")
    overdue_scope   = ppm_acts.where(status: "overdue")

    prev_completed_scope = prev_ppm.where(status: "complete")
    prev_pending_scope   = prev_ppm.where(status: ["pending", nil])
    prev_missed_scope    = prev_ppm.where(status: "missed")
    prev_overdue_scope   = prev_ppm.where(status: "overdue")


    pct = total > 0 ?
      (completed_scope.count.to_f / total * 100).round(1) : 0

    prev_pct = prev_total > 0 ?
      (prev_completed_scope.count.to_f / prev_total * 100).round(1) : 0


    {
      summary: {

        percentage: pct,
        prev_percentage: prev_pct,

        vs_last_period: (pct - prev_pct).round(1),

        completed: completed_scope.count,
        prev_completed: prev_completed_scope.count,

        pending: pending_scope.count,
        prev_pending: prev_pending_scope.count,

        missed: missed_scope.count,
        prev_missed: prev_missed_scope.count,

        overdue: overdue_scope.count,
        prev_overdue: prev_overdue_scope.count,

        total_scheduled: total,
        prev_total_scheduled: prev_total

      },

      records: {

        completed: completed_scope.limit(50),

        pending: pending_scope.limit(50),

        missed: missed_scope.limit(50),

        overdue: overdue_scope.limit(50)

      }

    }

  end

  def asset_health_data

    assets = SiteAsset.where(site_id: @site_ids)

    total = assets.count

    # Mutually exclusive status counts (priority: offline > critical > maintenance > operational)
    offline_count = assets.where(active: [false, 0]).count
    critical_count = assets.where("(active = 1 OR active IS NULL) AND critical = 1").count
    maintenance_count = assets.where("(active = 1 OR active IS NULL) AND (critical = 0 OR critical IS NULL) AND breakdown = 1").count
    operational_count = assets.where("(active = 1 OR active IS NULL) AND (breakdown = 0 OR breakdown IS NULL) AND (critical = 0 OR critical IS NULL)").count

    pct = total > 0 ? (operational_count.to_f / total * 100).round(1) : 0

    prev_assets = SiteAsset.where(site_id: @site_ids)
    prev_assets = prev_assets.where(updated_at: prev_period_range) if @date_range

    prev_total = prev_assets.count

    prev_operational_count = prev_assets.where("(active = 1 OR active IS NULL) AND (breakdown = 0 OR breakdown IS NULL) AND (critical = 0 OR critical IS NULL)").count

    prev_pct = prev_total > 0 ? (prev_operational_count.to_f / prev_total * 100).round(1) : 0

    {
      summary: {
        percentage: pct,
        prev_percentage: prev_pct,
        vs_last_period: (pct - prev_pct).round(1),

        operational: operational_count,
        prev_operational: prev_operational_count,

        maintenance: maintenance_count,

        critical: critical_count,

        offline: offline_count,

        total: total,
        prev_total: prev_total
      },

      records: {
        operational: assets.where("(active = 1 OR active IS NULL) AND (breakdown = 0 OR breakdown IS NULL) AND (critical = 0 OR critical IS NULL)").limit(50)
      }
    }

  end

  def workforce_availability_data
    staffs = Staff.where(site_id: @site_ids)
    staffs = staffs.where(vendor_id: @vendor_id) if @vendor_id.present?
    total = staffs.count
    ids = staffs.pluck(:id)
    today_attendances = Attendance
    .where(attendance_of_type: "Staff", attendance_of_id: ids)
    .where(punched_in_at: Time.now.utc.beginning_of_day..Time.now.utc.end_of_day)
    yesterday_attendances = Attendance
    .where(attendance_of_type: "Staff", attendance_of_id: ids)
    .where(punched_in_at: Date.yesterday.beginning_of_day.utc..Date.yesterday.end_of_day.utc)
    today_present = today_attendances.pluck(:attendance_of_id).uniq.size
    yesterday_present = yesterday_attendances.pluck(:attendance_of_id).uniq.size
    pct      = total > 0 ? (today_present.to_f / total * 100).round(1) : 0
    prev_pct = total > 0 ? (yesterday_present.to_f / total * 100).round(1) : 0
    {
      summary: {
        percentage:      pct,
        prev_percentage: prev_pct,
        vs_yesterday:    (pct - prev_pct).round(1),

        present:         today_present,
        prev_present:    yesterday_present,

        absent:          total - today_present,
        prev_absent:     total - yesterday_present,

        total:           total
      },

      records: {
        present: staffs.limit(50)
      }
    }
  end

  def vendor_sla_data
    vendors      = Vendor.where(site_id: @site_ids)
    total        = vendors.count
    thirty_days  = Date.today + 30
    today_date   = Date.today
    compliant = vendors.where(
      "aggremenet_end_date IS NULL OR aggremenet_end_date >= ?",
      thirty_days
    )
    at_risk = vendors.where(
      "aggremenet_end_date >= ? AND aggremenet_end_date < ?",
      today_date,
      thirty_days
    )
    non_compliant = vendors.where(
      "aggremenet_end_date < ?",
      today_date
    )
    pct = total > 0 ? (compliant.count.to_f / total * 100).round(1) : 0
    {
      summary: {
        percentage:      pct,
        prev_percentage: pct,
        vs_last_period:  0,
        compliant:       compliant.count,
        at_risk:         at_risk.count,
        non_compliant:   non_compliant.count,
        total:           total
      },
      records: {
        compliant:     compliant.limit(50).map { |v| serialize_vendor(v, 'Compliant') },
        at_risk:       at_risk.limit(50).map { |v| serialize_vendor(v, 'At Risk') },
        non_compliant: non_compliant.limit(50).map { |v| serialize_vendor(v, 'Non-Compliant') }
      }
    }
  end

  def compliance_score_data
    trackers = ComplianceTracker.where(site_id:@site_ids)
    trackers = trackers.where(created_at: @date_range) if @date_range
    prev = ComplianceTracker.where(site_id:@site_ids)
    prev = prev.where(created_at: prev_period_range) if @date_range
    total=trackers.count
    prev_total=prev.count
    compliant=trackers.where(status:%w[compliant complete])
    prev_compliant=prev.where(status:%w[compliant complete])
    pct=total>0 ?
      (compliant.count.to_f/total*100).round(1):0
    prev_pct=prev_total>0 ?
      (prev_compliant.count.to_f/prev_total*100).round(1):0
    {
      summary:{
        percentage:pct,
        prev_percentage:prev_pct,
        vs_last_period:(pct-prev_pct).round(1),
        compliant:compliant.count,
        prev_compliant:prev_compliant.count,
        non_compliant:trackers.where(status:%w[non_compliant failed]).count,
        pending:trackers.where(status:[nil,"pending","in_progress"]).count,
        total:total,
        prev_total:prev_total
      },
      records:{
        compliant:compliant.limit(50)
      }
    }
  end
  def visitors_today_data
    visits = VisitorVisit
    .joins(:visitor)
    .where(visitors: { site_id: @site_ids, is_deleted: false })
    .where(check_in: Time.now.utc.beginning_of_day..Time.now.utc.end_of_day)
    yesterday = VisitorVisit
    .joins(:visitor)
    .where(visitors: { site_id: @site_ids, is_deleted: false })
    .where(check_in: Date.yesterday.beginning_of_day.utc..Date.yesterday.end_of_day.utc)
    checked_in     = visits.pluck(:id).uniq.size
    yesterday_count = yesterday.pluck(:id).uniq.size
    checked_out    = visits.where.not(check_out: nil).count

    {
      summary: {
        checked_in:       checked_in,
        prev_checked_in:  yesterday_count,
        checked_out:      checked_out,
        currently_inside: [checked_in - checked_out, 0].max,
        vs_yesterday:     checked_in - yesterday_count
      },
      records: {
        visits: visits.limit(50)
      }
    }
  end

  def avg_resolution_time_data
    complaints=Complaint.where(site_id:@site_ids)
    complaints = complaints.where(created_at: @date_range) if @date_range
    prev=Complaint.where(site_id:@site_ids)
    prev = prev.where(created_at: prev_period_range) if @date_range
    avg=avg_resolution_hours(complaints)
    prev_avg=avg_resolution_hours(prev)
    {
      summary:{
        hours:avg,
        prev_hours:prev_avg,
        vs_last_period:(avg-prev_avg).round(1)
      },
      records:{
        complaints: complaints
        .where.not(resolution_time: nil)
        .includes(:complaint_status)
        .order(created_at: :desc)
        .limit(50)
        .map { |c| serialize_complaint(c) }
      }

    }

  end

  # ─── Query Helpers ────────────────────────────────────────────────────────────

  # PPM activities scoped to site_ids within an optional time range
  def ppm_activities_for(site_ids, range = nil)
    range = range || @date_range
    scope = Activity.joins(:checklist).where(checklists: { ctype: ['ppm', 'PPM'], site_id: site_ids })
    scope = scope.where(start_time: range) if range
    scope
  end

  # All checklist-based activities (PPM + routine + amc) scoped to site_ids
  def all_checklist_activities_for(site_ids, range = nil)
    range = range || @date_range
    scope = Activity.joins(:checklist).where(checklists: { site_id: site_ids })
    scope = scope.where(start_time: range) if range
    scope
  end

  # Soft-service activities scoped to site_ids within an optional time range
  def soft_service_activities_for(site_ids, range = nil)
    range = range || @date_range
    scope = Activity
    .joins(:soft_service)
    .where(soft_services: { site_id: site_ids })
    scope = scope.where(start_time: range) if range
    scope
  end

  def asset_status_label(asset)
    return "offline" if asset.active == false
    return "critical" if asset.critical == true
    return "maintenance" if asset.breakdown == true
    "operational"
  end

  def serialize_vendor(v, status)
    {
      id:           v.id,
      name:         v.vendor_name.presence || "Vendor ##{v.id}",
      expiry_date:  v.aggremenet_end_date,
      site_id:      v.site_id,
      active:       v.active,
      status:       status
    }
  end

  def serialize_complaint(c)
    {
      id:            c.id,
      ticket_number: c.ticket_number,
      heading:       c.heading,
      priority:      c.priority,
      sla_status:    c.resolution_breached ? 'Breached' : (c.response_breached ? 'At Risk' : 'Within SLA'),
      status:        c.complaint_status&.name,
      created_at:    c.created_at,
      resolution_time: c.resolution_time,
      site_id:       c.site_id
    }
  end

  # Average resolution time in hours for resolved complaints
  def avg_resolution_hours(complaints)
    resolved = complaints.where.not(resolution_time: nil)
    return 0.0 unless resolved.any?

    pairs  = resolved.pluck(:created_at, :resolution_time)
    total_seconds = pairs.sum { |created, resolved_at| (resolved_at - created).abs }
    (total_seconds / pairs.size / 3600.0).round(2)
  end

  # Previous period range (same duration, immediately before from_date)
  def prev_period_range
    return nil unless @from_date && @to_date
    duration = @to_date - @from_date
    prev_end   = @from_date - 1.second
    prev_start = prev_end - duration
    prev_start..prev_end
  end
end
