# Dashboard dummy seed - inserts 10+ records for testing grouped dashboard
# Run: cd optimus_prime && rails runner db/seeds/dashboard_dummy.rb
# DB: vibe, user: akshay, pass: akshay@1A
# Note: Complaints require Redis (start with: redis-server). Other records work without Redis.

puts "=== Dashboard Dummy Seed ==="

company = Company.first_or_create!(name: "Vibe FM Company")
site = Site.find_or_create_by!(name: "Commercial Plaza Alpha") do |s|
  s.region = "Mumbai"
  s.active = true
  s.company_id = company.id
end

# Ensure we have a user for site_assets and staff created_by
user = User.find_by(email: "dashboard@vibe.local")
unless user
  begin
    user = User.create!(
      email: "dashboard@vibe.local",
      password: "Password123!",
      firstname: "Dashboard",
      lastname: "System",
      company_id: company.id
    )
  rescue
    user = User.first
  end
end
raise "No User exists. Create a user first." unless user

# 2 Blocks (buildings) - commercial site terminology
blocks = []
2.times do |i|
  name = "Block #{('A'.ord + i).chr} - #{site.name}"
  b = Building.find_or_create_by!(name: name, site_id: site.id) do |bl|
    bl.floor_no = "B#{i + 1}"
  end
  blocks << b
end

# Floors per block, units per floor
floors = []
units_list = []
blocks.each do |block|
  2.times do |j|
    f = Floor.find_or_create_by!(name: "Level #{j + 1}", building_id: block.id, site_id: site.id)
    floors << f
    u = Unit.find_or_create_by!(name: "Unit #{block.name.gsub(/\s+/, '')}-L#{j + 1}-01", building_id: block.id, floor_id: f.id, site_id: site.id)
    units_list << u
  end
end

# Asset groups
groups = []
%w[Electrical HVAC Fire\ Safety].each do |gname|
  ag = AssetGroup.find_or_create_by!(name: gname, company_id: company.id)
  groups << ag
end

# 10 Site assets - mix of operational, maintenance, critical, offline
10.times do |i|
  floor = floors[i % floors.size]
  block = floor.building
  group = groups[i % groups.size]
  status = %w[operational operational operational maintenance maintenance critical offline operational operational maintenance][i]
  SiteAsset.find_or_create_by!(name: "Asset #{i + 1} - #{group.name}", site_id: site.id) do |a|
    a.building_id = block.id
    a.floor_id = floor.id
    a.asset_group_id = group.id
    a.user_id = user.id
    a.asset_number = "AST-#{1000 + i}"
    a.active = status != "offline"
    a.breakdown = status == "maintenance"
    a.critical = status == "critical"
  end
rescue => e
  puts "  SiteAsset #{i + 1} skip: #{e.message}"
end

# Complaint statuses (use existing or create with society_id from first site)
society_id = 1
open_status = ComplaintStatus.find_or_create_by!(name: "Open", society_id: society_id) { |cs| cs.fixed_state = "open"; cs.active = 1 }
closed_status = ComplaintStatus.find_or_create_by!(name: "Resolved", society_id: society_id) { |cs| cs.fixed_state = "closed"; cs.active = 1 }

# Helpdesk categories for proper ticket categorization (avoids "Uncategorized")
helpdesk_cats = %w[AC\ Repair Lighting Pest\ Control Plumbing Elevator Cleanliness Security HVAC Electrical General\ Maintenance].map do |name|
  HelpdeskCategory.find_or_create_by!(name: name, society_id: society_id) { |hc| hc.active = 1 }
end

# 10 Complaints (tickets) - requires Redis for Complaint callbacks; skip if Redis down
10.times do |i|
  st = i < 6 ? open_status : closed_status
  next if Complaint.exists?(ticket_number: "TKT-#{2000 + i}", site_id: site.id)
  Complaint.find_or_create_by!(ticket_number: "TKT-#{2000 + i}", site_id: site.id) do |c|
    c.heading = "Dummy ticket #{i + 1} - #{%w[AC repair Lighting Pest control Plumbing Elevator Cleanliness Security HVAC Electrical General][i % 10]}"
    c.issue_status = st.id.to_s
    c.category_type_id = helpdesk_cats[i % helpdesk_cats.size].id
    c.priority = %w[Low Medium High Medium Low High Low Medium Medium Low][i]
    c.response_breached = (i == 2)
    c.resolution_breached = (i == 1 || i == 3)
    c.created_at = (10 - i).days.ago
  end
rescue => e
  puts "  Complaint #{i + 1} skip: #{e.message}"
end

# 2 Vendors
vendors = []
2.times do |i|
  v = Vendor.find_or_create_by!(vendor_name: "Vendor #{('X'.ord + i).chr} Services", site_id: site.id) do |vr|
    vr.active = true
    vr.aggremenet_end_date = 1.year.from_now
  end
  vendors << v
end

# 10 Staff (created_by_id optional - omit to avoid callback/validation issues)
10.times do |i|
  vendor = vendors[i % 2]
  Staff.find_or_create_by!(mobile_no: "99999#{10000 + i}", site_id: site.id) do |s|
    s.firstname = "Staff"
    s.lastname = "#{i + 1}"
    s.email = "staff#{i + 1}@vibe.local"
    s.work_type = %w[Housekeeping Security Maintenance Electrical HVAC Plumbing General Cleaner Technician Guard][i % 10]
    s.vendor_id = vendor.id
    s.status = true
    s.creator_user_type = "pms_admin"
  end
rescue => e
  puts "  Staff #{i + 1} skip: #{e.message}"
end

# PPM: Checklist + Activities (Checklist requires user_id)
checklist = Checklist.find_or_create_by!(name: "PPM Dummy", site_id: site.id, ctype: "ppm") do |c|
  c.user_id = user.id
  c.active = true
  c.frequency = "weekly"
  c.start_date = 1.month.ago.to_date
  c.end_date = 1.year.from_now.to_date
end

assets = SiteAsset.where(site_id: site.id).limit(5)
assets.each_with_index do |asset, i|
  Activity.find_or_create_by!(asset_id: asset.id, checklist_id: checklist.id, start_time: (5 - i).days.ago.beginning_of_day + 9.hours) do |a|
    a.status = i < 3 ? "completed" : (i == 3 ? "missed" : "pending")
    a.end_time = (5 - i).days.ago.beginning_of_day + 10.hours if i < 3
  end
rescue => e
  puts "  Activity #{i + 1} skip: #{e.message}"
end

# Attendance (workforce present today) - 5 staff present (Attendance requires resource: Site)
staff_ids = Staff.where(site_id: site.id).limit(7).pluck(:id)
staff_ids.first(5).each_with_index do |sid, i|
  punched_at = Date.today.to_time + 8.hours
  next if Attendance.where(attendance_of_type: "Staff", attendance_of_id: sid).where("DATE(punched_in_at) = ?", Date.today).exists?
  Attendance.create!(
    attendance_of_type: "Staff",
    attendance_of_id: sid,
    resource_type: "Site",
    resource_id: site.id,
    punched_in_at: punched_at
  )
rescue => e
  puts "  Attendance #{i + 1} skip: #{e.message}"
end

puts "Done. Created/updated:"
puts "  Site: #{site.name}"
puts "  Blocks: #{blocks.size}"
puts "  Floors: #{floors.size}"
puts "  Units: #{units_list.size}"
puts "  Assets: #{SiteAsset.where(site_id: site.id).count}"
puts "  Complaints: #{Complaint.where(site_id: site.id).count}"
puts "  Vendors: #{Vendor.where(site_id: site.id).count}"
puts "  Staff: #{Staff.where(site_id: site.id).count}"
puts "  PPM Activities: #{Activity.joins(:checklist).where(checklists: { ctype: 'ppm', site_id: site.id }).count}"
puts "  Attendances today: #{Attendance.where(attendance_of_type: 'Staff', attendance_of_id: staff_ids).where('DATE(punched_in_at) = ?', Date.today).count}"
