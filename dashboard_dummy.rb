# Dashboard dummy seed - creates FRESH 10+ records every run (no find_or_create conflicts)
# Run: cd optimus_prime && rails runner db/seeds/dashboard_dummy.rb
# DB: vibe, user: akshay, pass: akshay@1A
# Note: Complaints require Redis (start with: redis-server). Other records work without Redis.

puts "=== Dashboard Dummy Seed (Fresh Run) ==="

# Unique suffix to avoid name collisions on repeated runs
SUFFIX = Time.now.strftime("%Y%m%d%H%M%S")

# ── Company & Site ──────────────────────────────────────────────────────────────
company = Company.first_or_create!(name: "Vibe FM Company")

site = Site.create!(
  name:       "Commercial Plaza #{SUFFIX}",
  region:     "Mumbai",
  active:     true,
  company_id: company.id
)
puts "  Site: #{site.name}"

# ── User ────────────────────────────────────────────────────────────────────────
user = User.find_by(email: "dashboard@vibe.local")
unless user
  begin
    user = User.create!(
      email:      "dashboard@vibe.local",
      password:   "Password123!",
      firstname:  "Dashboard",
      lastname:   "System",
      company_id: company.id
    )
  rescue
    user = User.first
  end
end
raise "No User found. Please create one first." unless user

# ── 2 Blocks (Buildings) ────────────────────────────────────────────────────────
blocks = (0...2).map do |i|
  Building.create!(
    name:    "Block #{('A'.ord + i).chr} - #{site.name}",
    site_id: site.id,
    floor_no: "B#{i + 1}"
  )
end
puts "  Blocks: #{blocks.size}"

# ── 5 Floors (spread across blocks) ────────────────────────────────────────────
floors = []
5.times do |j|
  floors << Floor.create!(
    name:        "Level #{j + 1}",
    building_id: blocks[j % 2].id,
    site_id:     site.id
  )
end
puts "  Floors: #{floors.size}"

# ── 10 Units ────────────────────────────────────────────────────────────────────
units_list = []
10.times do |i|
  floor = floors[i % floors.size]
  units_list << Unit.create!(
    name:        "Unit-#{SUFFIX}-#{i + 1}",
    building_id: floor.building_id,
    floor_id:    floor.id,
    site_id:     site.id
  )
end
puts "  Units: #{units_list.size}"

# ── Asset Groups ────────────────────────────────────────────────────────────────
group_names = ["Electrical", "HVAC", "Fire Safety"]
groups = group_names.map do |gname|
  AssetGroup.find_or_create_by!(name: gname, company_id: company.id)
end

# ── 10 Site Assets ──────────────────────────────────────────────────────────────
statuses = %w[operational operational operational maintenance maintenance
              critical offline operational operational maintenance]

10.times do |i|
  floor  = floors[i % floors.size]
  group  = groups[i % groups.size]
  status = statuses[i]
  begin
    SiteAsset.create!(
      name:           "Asset #{i + 1} - #{group.name} [#{SUFFIX}]",
      site_id:        site.id,
      building_id:    floor.building_id,
      floor_id:       floor.id,
      asset_group_id: group.id,
      user_id:        user.id,
      asset_number:   "AST-#{SUFFIX}-#{i + 1}",
      active:         status != "offline",
      breakdown:      status == "maintenance",
      critical:       status == "critical"
    )
  rescue => e
    puts "  SiteAsset #{i + 1} skip: #{e.message}"
  end
end
puts "  Assets: #{SiteAsset.where(site_id: site.id).count}"

# ── Complaint Statuses ──────────────────────────────────────────────────────────
society_id   = 1
open_status  = ComplaintStatus.find_or_create_by!(name: "Open",     society_id: society_id) { |cs| cs.fixed_state = "open";   cs.active = 1 }
closed_status = ComplaintStatus.find_or_create_by!(name: "Resolved", society_id: society_id) { |cs| cs.fixed_state = "closed"; cs.active = 1 }

# ── 10 Complaints ───────────────────────────────────────────────────────────────
topics     = %w[AC\ repair Lighting Pest\ control Plumbing Elevator Cleanliness Security HVAC Electrical General]
priorities = %w[Low Medium High Medium Low High Low Medium Medium Low]

10.times do |i|
  begin
    Complaint.create!(
      ticket_number:        "TKT-#{SUFFIX}-#{i + 1}",
      site_id:              site.id,
      heading:              "Ticket #{i + 1} - #{topics[i % 10]} [#{SUFFIX}]",
      issue_status:         (i < 6 ? open_status : closed_status).id.to_s,
      priority:             priorities[i],
      response_breached:    (i == 2),
      resolution_breached:  (i == 1 || i == 3),
      created_at:           (10 - i).days.ago
    )
  rescue => e
    puts "  Complaint #{i + 1} skip: #{e.message}"
  end
end
puts "  Complaints: #{Complaint.where(site_id: site.id).count}"

# ── 10 Vendors ──────────────────────────────────────────────────────────────────
vendors = 10.times.map do |i|
  begin
    Vendor.create!(
      vendor_name:       "Vendor #{i + 1} Services [#{SUFFIX}]",
      site_id:           site.id,
      active:            true,
      aggremenet_end_date: 1.year.from_now
    )
  rescue => e
    puts "  Vendor #{i + 1} skip: #{e.message}"
    nil
  end
end.compact
puts "  Vendors: #{vendors.size}"

# ── 10 Staff ────────────────────────────────────────────────────────────────────
work_types = %w[Housekeeping Security Maintenance Electrical HVAC Plumbing General Cleaner Technician Guard]

10.times do |i|
  begin
    Staff.create!(
      firstname:         "Staff",
      lastname:          "#{SUFFIX}-#{i + 1}",
      email:             "staff#{SUFFIX}#{i + 1}@vibe.local",
      mobile_no:         "9#{SUFFIX[-9..-1]}#{i}",
      site_id:           site.id,
      work_type:         work_types[i % 10],
      vendor_id:         vendors[i % vendors.size].id,
      status:            true,
      creator_user_type: "pms_admin"
    )
  rescue => e
    puts "  Staff #{i + 1} skip: #{e.message}"
  end
end
puts "  Staff: #{Staff.where(site_id: site.id).count}"

# ── PPM Checklist + 10 Activities ───────────────────────────────────────────────
checklist = Checklist.create!(
  name:       "PPM Dummy [#{SUFFIX}]",
  site_id:    site.id,
  ctype:      "ppm",
  user_id:    user.id,
  active:     true,
  frequency:  "weekly",
  start_date: 1.month.ago.to_date,
  end_date:   1.year.from_now.to_date
)

site_assets = SiteAsset.where(site_id: site.id).limit(10)
site_assets.each_with_index do |asset, i|
  begin
    Activity.create!(
      asset_id:     asset.id,
      checklist_id: checklist.id,
      start_time:   (10 - i).days.ago.beginning_of_day + 9.hours,
      end_time:     i < 7 ? (10 - i).days.ago.beginning_of_day + 10.hours : nil,
      status:       i < 7 ? "completed" : (i == 7 ? "missed" : "pending")
    )
  rescue => e
    puts "  Activity #{i + 1} skip: #{e.message}"
  end
end
puts "  PPM Activities: #{Activity.joins(:checklist).where(checklists: { ctype: 'ppm', site_id: site.id }).count}"

# ── 10 Attendance Records ────────────────────────────────────────────────────────
staff_ids = Staff.where(site_id: site.id).pluck(:id)
staff_ids.first(10).each_with_index do |sid, i|
  begin
    Attendance.create!(
      attendance_of_type: "Staff",
      attendance_of_id:   sid,
      resource_type:      "Site",
      resource_id:        site.id,
      punched_in_at:      Date.today.to_time + (7 + i * 0.5).hours
    )
  rescue => e
    puts "  Attendance #{i + 1} skip: #{e.message}"
  end
end
puts "  Attendances today: #{Attendance.where(attendance_of_type: 'Staff', attendance_of_id: staff_ids).where('DATE(punched_in_at) = ?', Date.today).count}"

# ── Summary ──────────────────────────────────────────────────────────────────────
puts ""
puts "=== Done! Fresh seed created with suffix: #{SUFFIX} ==="
puts "  Site        : #{site.name} (id: #{site.id})"
puts "  Blocks      : #{blocks.size}"
puts "  Floors      : #{floors.size}"
puts "  Units       : #{units_list.size}"
puts "  Assets      : #{SiteAsset.where(site_id: site.id).count}"
puts "  Complaints  : #{Complaint.where(site_id: site.id).count}"
puts "  Vendors     : #{Vendor.where(site_id: site.id).count}"
puts "  Staff       : #{Staff.where(site_id: site.id).count}"
puts "  PPM Acts    : #{Activity.joins(:checklist).where(checklists: { ctype: 'ppm', site_id: site.id }).count}"
puts "  Attendances : #{Attendance.where(attendance_of_type: 'Staff', attendance_of_id: staff_ids).where('DATE(punched_in_at) = ?', Date.today).count}"
