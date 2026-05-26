class Staff < ApplicationRecord
  belongs_to :site
  # Multiple Units For that staff
  has_many :staff_units , dependent: :destroy
  has_many :units, through: :staff_units, validate: false
  belongs_to :vendor, optional: true
  after_create :create_qr
  has_many :attendances, class_name: "Attendance", foreign_key: :attendance_of_id ,dependent: :destroy
  has_one :profile_picture, -> { where(relation: "StaffProfilePicture") }, foreign_key: :relation_id, class_name: "Attachfile", dependent: :destroy
  has_one :qr_code_image, ->{where(relation: "StaffQR") }, :foreign_key => :relation_id, :class_name => "Attachfile"
  serialize :working_schedule, JSON
  after_create :generate_unique_staff_id
  before_validation :set_status_type
  belongs_to :user, class_name: 'User', foreign_key: 'created_by_id', optional: true
  after_create :set_security_status
  validates :mobile_no , uniqueness: { scope: :site_id }
  # serialize :unit_id, Array
  attr_accessor :creator_user_type

  def set_status_type
    if self.creator_user_type == 'pms_admin'
      self.status_type = 'Approved'
    else
      self.status_type ||= 'Pending'
    end
  end

    ransacker :search do |parent|
   Arel.sql(
    "CONCAT_WS(' ',
        staffs.id,
        staffs.firstname,
        staffs.lastname,
        staffs.email,
        staffs.mobile_no,
        staffs.work_type,
        staffs.staff_id,
        staffs.status_type,
        users.firstname,
        users.lastname,
        units.name,
        vendors.vendor_name
      )"
    )
  end

  after_commit :notify_unit_users, on: :create
  
  def notify_unit_users
    staff = Staff.includes(:units, :site).find_by(id: self.id)
    return unless staff&.units&.any?

    # get all users associated with staff's units through UserSite
    unit_ids = staff.units.pluck(:id)
    users = User.joins(:user_sites).where(user_sites: { unit_id: unit_ids}).includes(:user_devices).distinct

    return if users.empty?

    devices = users.flat_map(&:user_devices)
    return if devices.empty?

    sendata = {
      title: "New Staff Added",
      message: "#{staff.full_name} has been added as staff in the complex",
      ntype: "staff",
      user_id: nil,
      company_id: staff.site.company_id,
      record_id: staff.id 
    }

    PushNotification.push_to_devices(devices, sendata)
  end


  def notify_unit_users_on_entry
    return if units.empty?

    # Optimized query - fetch users with their devices in one go
    users = User.joins(:user_sites)
                .where(user_sites: { unit_id: units.pluck(:id) })
                .includes(:user_devices)
                .distinct

    return if users.empty?

    devices = users.flat_map(&:user_devices)
    return if devices.empty?

    sendata = {
      title: "Staff IN",
      message: "#{full_name} has entered the complex",
      ntype: "staff",
      user_id: nil,
      company_id: site.company_id,
      record_id: id
    }
    
    PushNotification.push_to_devices(devices, sendata)
  end

  def notify_unit_users_on_exit
    return if units.empty?

    # Optimized query - fetch users with their devices in one go
    users = User.joins(:user_sites)
                .where(user_sites: { unit_id: units.pluck(:id) })
                .includes(:user_devices)
                .distinct

    return if users.empty?

    devices = users.flat_map(&:user_devices)
    return if devices.empty?

    sendata = {
      title: "Staff OUT",
      message: "#{full_name} has exited the complex",
      ntype: "staff",
      user_id: nil,
      company_id: site.company_id,
      record_id: id
    }
    
    PushNotification.push_to_devices(devices, sendata)
  end


  def generate_unique_staff_id
    loop do
      new_id = "STF#{SecureRandom.hex(2).upcase}"
      unless Staff.exists?(staff_id: new_id)
        update_column(:staff_id, new_id)
        break
      end
    end
  end

  # Chnage Status When Valid Till date passes
  def self.deactivate_expired_staff
    where("valid_till < ? AND status = ?", Time.current, true).update_all(status: false)
  end

  def full_name
    self.firstname + " " + self.lastname
  end

  def initialize_working_schedule
    self.working_schedule ||= {}
    Date::DAYNAMES.each do |day|
      self.working_schedule[day] ||= { 'selected' => false, 'start_time' => '', 'end_time' => '' }
    end
  end

  def filtered_working_schedule
    return {} if working_schedule.nil?
    
    working_schedule.select do |day, times|
      times.is_a?(Hash) && times['start_time'].present? && times['end_time'].present?
    end
  end

  def create_qr
    qr_code = RQRCode::QRCode.new("Staff_#{self.id}", size: 10, level: :h)
    png = qr_code.as_png(
      resize_gte_to: false,
      resize_exactly_to: false,
      fill: 'white',
      color: 'black',
      size: 200,
      border_modules: 4,
      module_px_size: 6,
      file: nil # path to write
    )
    png.save("tmp/staff_#{self.id}.png")
    file = File.open("tmp/staff_#{self.id}.png", "r")
    Attachfile.create(image: file, relation: "StaffQR", relation_id: self.id, active: 1)
  end

private

def set_security_status
  self.update(status: true) unless creator_user_type != 'pms_admin'
end

end
