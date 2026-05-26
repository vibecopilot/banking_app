class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable,:omniauthable, omniauth_providers: %i[facebook]

  # Encrypt Microsoft OAuth tokens at rest
  attr_encrypted :microsoft_access_token,
    key: (ENV['ENCRYPTION_KEY'] || 'a' * 32)[0..31]
  attr_encrypted :microsoft_refresh_token,
    key: (ENV['ENCRYPTION_KEY'] || 'a' * 32)[0..31]
  has_many :projects
  has_many :user_sites, dependent: :destroy
  has_many :sites, through: :user_sites
  accepts_nested_attributes_for :user_sites, allow_destroy: true
  belongs_to :unit, optional: true
  has_many :service_bookings, dependent: :destroy
  has_many :room_bookings, dependent: :destroy
  before_save :set_apikey
  has_many :hosts
  # User members
  has_many :user_members, dependent: :destroy
  has_many :user_vendors, dependent: :destroy
  has_many :vehicle_details, dependent: :destroy
  has_many :pets, dependent: :destroy
  accepts_nested_attributes_for :pets
  accepts_nested_attributes_for :user_members, allow_destroy: true
  accepts_nested_attributes_for :user_vendors, allow_destroy: true
  accepts_nested_attributes_for :vehicle_details, allow_destroy: true
  has_many :amenity_notifications
  has_many :user_portal_accesses, dependent: :destroy
  has_many :portals, through: :user_portal_accesses
  has_many :saml_temp_tokens, dependent: :destroy
  has_many :visitors, foreign_key: 'created_by_id', dependent: :destroy
  has_many :cards, dependent: :destroy
  after_create :welcome_email
  after_create :admin_approve
  after_create :sync_to_external_api_if_company_56
  after_create :assign_access_if_company_56
  after_create :fetch_cards_if_company_56
  after_create :assign_tag_if_company_56
  # after_create :otp_requestnal_api_if_company_56
  # after_create :otp_request
  has_many :attendances, as: :attendance_of
  belongs_to :vendor, class_name: "Vendor", foreign_key: "vendor_id", optional: true
  belongs_to :organization, class_name: "Organization", foreign_key: "organization_id", optional: true
  belongs_to :company, class_name: "Company", foreign_key: "company_id", optional: true
  belongs_to :helpdesk_category, optional: true
  belongs_to :helpdesk_sub_category, optional: true
  belongs_to :site, class_name: "Site", foreign_key: "current_site_id", optional: true
  has_and_belongs_to_many :groups, join_table: "communication_groups_users", dependent: :destroy
  has_many :user_devices, class_name: "UserDevice", foreign_key: "user_id", dependent: :destroy
  # has_many :notifications, dependent: :destroy
  # User Documents
  has_many :user_docs, -> { where(relation: 'UserDocuments') }, class_name: 'Attachfile', foreign_key: 'relation_id'
  # default_scope { where("users.active = true") }
  has_and_belongs_to_many :communication_groups , dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :income_entries, dependent: :destroy

  has_many :liked_forums, through: :likes, source: :forum
  has_many :saved_forums, dependent: :destroy
  has_many :saved_forum_entries, through: :saved_forums, source: :forum
  has_attached_file :profile_image,
    styles: { medium: "300x300>", thumb: "100x100>" },
    default_url: "/images/default_profile.png"
  validates_attachment_content_type :profile_image, content_type: /\Aimage\/.*\z/
  scope :employees, -> { where(user_type: 'employee') }
  # validates :mobile, presence: true, uniqueness: true

  def verify_otp(input_otp)
    return false unless self.otp.present? && self.otp.to_i == input_otp
    self. update!(otp: nil)
    true
  end

  def full_unit_name
    unit_record =
    if user_sites.first&.unit_id.present?
      Unit.includes(:building, :floor).find_by(id: user_sites.first.unit_id)
    elsif unit_id.present?
      Unit.includes(:building, :floor).find_by(id: unit_id)
    end
    if unit_record
      [
        unit_record.building&.name,
        unit_record.floor&.name,
        unit_record.name
      ].compact.join('-')
    end
  end

  def admin_approve
    current_user = User.current
    if current_user&.user_type == "pms_admin"
      update(user_status: true)
      # elsif self.user_status == true
      #   update(user_status: true)
    else
      update(user_status: false)
    end
  end

  def full_name
    firstname + " " + lastname
  end

  def set_apikey
    self.api_key = SecureRandom.hex(24) if !self.api_key.present?
  end

  def lock_user_permission
    self
  end

  def self.soc_admins
    where(user_type: "admin")
  end

  # SSO login via JumpCloud SAML
  def self.from_saml(saml_response)
    email      = saml_response.nameid.to_s.downcase.strip
    attrs      = saml_response.attributes
    first_name = attrs['firstName'].try(:first) || attrs['firstname'].try(:first) || ''
    last_name  = attrs['lastName'].try(:first)  || attrs['lastname'].try(:first)  || ''

    # Always find by email first — never create a duplicate
    user = find_by(email: email)

    if user
      # Update SSO fields on existing user
      user.update_columns(
        sso_uid:      email,
        sso_provider: 'jumpcloud'
      )
      user
    else
      # Only create if no user with this email exists at all
      create!(
        email:        email,
        firstname:    first_name.presence || 'Employee',
        lastname:     last_name.presence  || 'User',
        password:     SecureRandom.hex(16),
        user_type:    'employee',
        sso_uid:      email,
        sso_provider: 'jumpcloud',
        user_status:  true
      )
    end
  end

  # ─── Microsoft OAuth ────────────────────────────────────────────────────────

  # Called after Microsoft OAuth callback.
  # Finds existing user by email. If not found, creates new user with company_id=55 and current_site_id=100.
  def self.from_microsoft(ms_email, ms_uid, access_token, refresh_token, expires_at)
    email = ms_email.to_s.downcase.strip
    user  = unscoped.find_by(email: email)

    # If user doesn't exist, create new user
    unless user
      Rails.logger.info("[Microsoft OAuth] Creating new user: #{email}")
      begin
        password = SecureRandom.hex(16)
        user = create!(
          email: email,
          firstname: email.split('@').first.capitalize,
          lastname: 'User',
          password: password,
          password_confirmation: password,
          user_type: 'pms_admin',
          company_id: 55,
          current_site_id: 100,
          active: true
        )
        Rails.logger.info("[Microsoft OAuth] New user created: #{email} (ID: #{user.id})")
      rescue StandardError => e
        Rails.logger.error("[Microsoft OAuth] Failed to create user #{email}: #{e.message}")
        return nil
      end
    end

    user.update_columns(
      microsoft_uid:              ms_uid,
      microsoft_token_expires_at: expires_at
    )
    user.microsoft_access_token  = access_token
    user.microsoft_refresh_token = refresh_token
    user.save!
    user.auto_assign_portals
    user
  end

  # Auto-assign all active portals on login
  def auto_assign_portals
    Portal.active.each do |portal|
      UserPortalAccess.find_or_create_by!(user: self, portal: portal)
    end
  rescue StandardError => e
    Rails.logger.error("[SSO] Failed to auto-assign portals for #{email}: #{e.message}")
  end

  # Returns a valid access token, refreshing silently if expired
  def valid_microsoft_token
    return microsoft_access_token if microsoft_token_expires_at.present? &&
      microsoft_token_expires_at > 5.minutes.from_now
    refresh_microsoft_token
    microsoft_access_token
  end

  def self.from_omniauth(auth)    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|      user.email = auth.info.email
      user.password = Devise.friendly_token[0,20]
      user.firstname = auth.info.name   # assuming the user model has a name
      user.image = auth.info.image # assuming the user model has an image
      # If you are using confirmable and the provider(s) you use validate emails,
      # uncomment the line below to skip the confirmation emails.
      # user.skip_confirmation!
    end
  end

  def self.current=(usr)
    Thread.current[:current_user] = usr
  end
  def self.current
    Thread.current[:current_user]
  end

  def fullname
    self.firstname + " " + self.lastname
  end

  def pms_occupant_admin?
    self.user_type == 'pms_occupant_admin'
  end

  def pms_admin?
    %w(pms_admin pms_organization_admin).include?(self.user_type)
  end

  def fb_admin?
    pms_admin?
  end

  def employee?
    %w(employee).include?(self.user_type)
  end

  def pms_occupant?
    %w(pms_occupant pms_occupant_admin).include?(self.user_type)
  end

  def pms_accounts?
    %w(pms_accounts pms_hse pms_se pms_po pms_qc).include?(self.user_type)
  end

  def welcome_email
    UserMailer.new_user_welcome_mailer(self, password).deliver_now
  rescue EOFError => e
    Rails.logger.error "Failed to send welcome email to #{email}: #{e.message}"
  end

  def self.import(file, current_user)
    spreadsheet = Roo::Spreadsheet.open(file.path)
    header = spreadsheet.row(1)
    rowcomp = []
    rows = []
    company_names = {}
    unit_names = {}
    unit_site_ids = {}
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      rows << [i, row]
      company_name = row["CompanyName"].to_s.strip
      company_names[company_name] = true if company_name.present?
      if row["UnitName"].present? && row["SiteIds"].present?
        site_id = row["SiteIds"].to_s.split(",").first.to_s.strip
        unit_name = row["UnitName"].to_s.strip
        unit_site_ids[site_id] = true if site_id.present?
        unit_names[unit_name] = true if unit_name.present?
      end
    end
    companies_by_name = {}
    if company_names.any?
      Company.where(name: company_names.keys)
      .select(:id, :name)
      .find_each do |company|
        companies_by_name[company.name.to_s.strip] = company
      end
    end
    units_by_site_and_name = {}
    if unit_site_ids.any? && unit_names.any?
      Unit.where(site_id: unit_site_ids.keys, name: unit_names.keys)
      .select(:id, :site_id, :name)
      .find_each do |unit|
        units_by_site_and_name[[unit.site_id.to_s, unit.name.to_s.strip]] = unit
      end
    end
    rows.each do |(i, row)|
      rowhs = {}
      rowhs[:row_number] = i
      user =
      if row["Id"].present?
        User.find_or_initialize_by(id: row["Id"])
      else
        User.new
      end
      user.firstname = row["FirstName"]
      user.lastname  = row["LastName"]
      user.email     = row["Email"]
      user.mobile    = row["Mobile"]
      user.password  = row["Password"]
      user.user_type = row["Type"] if row["Type"].present?
      if row["CompanyName"].present?
        company = companies_by_name[row["CompanyName"].to_s.strip]
        user.company_id = company.id if company.present?
      end
      if row["UnitName"].present? && row["SiteIds"].present?
        site_id   = row["SiteIds"].to_s.split(",").first.strip
        unit_name = row["UnitName"].to_s.strip
        unit = units_by_site_and_name[[site_id.to_s, unit_name]]
        unless unit
          rowhs[:message] = "Unit '#{unit_name}' not found for Site #{site_id} (User: #{row["FirstName"]} #{row["LastName"]})"
          rowcomp << rowhs
          next
        end
        user.unit_id = unit.id
      else
        rowhs[:message] = "UnitName or SiteIds missing (User: #{row["FirstName"]} #{row["LastName"]})"
        rowcomp << rowhs
        next
      end
      unless user.save
        rowhs[:message] = user.errors.full_messages.join(", ")
        rowcomp << rowhs
        next
      end
      if row["BuildingIdSiteId"].present?
        # Format: "building_id,site_id" e.g. "151,59"
        parts = row["BuildingIdSiteId"].to_s.split(",").map(&:strip)
        building_id = parts[0]
        site_id = parts[1]

        if building_id.present? && site_id.present?
          existing = UserSite.find_by(user_id: user.id, site_id: site_id, build_id: building_id, unit_id: unit&.id)

          unless existing
            UserSite.create(
              user_id: user.id,
              site_id: site_id,
              build_id: building_id,
              unit_id: unit&.id
            )
          end
        end
      elsif row["SiteIds"].present?
        # Fallback: create UserSite with site and unit only (no building)
        site_id = row["SiteIds"].to_s.split(",").first.strip
        existing = UserSite.find_by(user_id: user.id, site_id: site_id, unit_id: unit&.id)

        unless existing
          UserSite.create(
            user_id: user.id,
            site_id: site_id,
            unit_id: unit&.id
          )
        end
      end
      if row["CarpetArea"].present? || row["CamStartDate"].present?
        cam_config = CamUnitConfig.find_or_initialize_by(unit_id: unit.id)

        cam_config.carpet_area_sqft = row["CarpetArea"]
        cam_config.cam_start_date = row["CamStartDate"].presence || Date.current
        cam_config.advance_amount = row["AdvanceAmount"].presence || 0

        unless cam_config.save
          rowhs[:message] = "CAM config error: #{cam_config.errors.full_messages.join(', ')}"
          rowcomp << rowhs
          next
        end
      end
      if row["SiteIds"].present?
        current_site_id = row["SiteIds"].to_s.split(",").first.strip
        user.update_column(:current_site_id, current_site_id)
      end
      rowhs[:message] = "success"
      rowcomp << rowhs
    end
    rowcomp
  end

  def selected_site_id
    self.current_site_id
  end

  def available_site
  end

  def user_type_str
    ut = self.user_type
    return "Admin" if ut == "pms_admin"
    return "Technician" if ut == "pms_technician"
    return "Unit Owner" if ut == "pms_occupant_admin"
    return "Unit Resident" if ut == "pms_occupant"
    return "Face Scanner" if ut == "face_scanner"
    return "Approving Authority" if ut == "Tm"
    return "Security Guard" if ut == "security_guard"
    return "House Keeping" if ut == "house_keeping"
    return "Employee" if ut == "employee"
  end

  def as_json(options = {})
    super(options).merge(
      profile_image_url: profile_image.url(:medium),
      profile_image_thumb_url: profile_image.url(:thumb)
    )
  end

  def inactive_lup?
    return false
  end

  private

  def refresh_microsoft_token
    return unless microsoft_refresh_token.present?

    require 'net/http'
    uri  = URI(MICROSOFT_TOKEN_URL)
    res  = Net::HTTP.post_form(uri, {
                                 'client_id'     => MICROSOFT_OAUTH_CONFIG[:client_id],
                                 'client_secret' => MICROSOFT_OAUTH_CONFIG[:client_secret],
                                 'grant_type'    => 'refresh_token',
                                 'refresh_token' => microsoft_refresh_token,
                                 'scope'         => MICROSOFT_OAUTH_CONFIG[:scopes]
    })
    data = JSON.parse(res.body)

    if data['access_token']
      self.microsoft_access_token     = data['access_token']
      self.microsoft_refresh_token    = data['refresh_token'] if data['refresh_token']
      self.microsoft_token_expires_at = Time.current + data['expires_in'].to_i.seconds
      save!
    else
      Rails.logger.error("[Microsoft] Token refresh failed for user #{id}: #{data['error_description']}")
    end
  rescue StandardError => e
    Rails.logger.error("[Microsoft] Token refresh exception for user #{id}: #{e.message}")
  end

  def sync_to_external_api_if_company_56
    return unless company_id == 56

    begin
      service = ExternalUserSyncService.new(self, 56)
      result = service.sync

      if result[:success]
        Rails.logger.info("User #{id} synced to external API successfully")
      else
        Rails.logger.error("Failed to sync user #{id} to external API: #{result[:error]}")
      end
    rescue StandardError => e
      Rails.logger.error("Error syncing user #{id} to external API: #{e.message}")
    end
  end

  def fetch_cards_if_company_56
    return unless company_id == 56
    return unless lotus_token.present?

    begin
      service = CardInventoryService.new(self, 56)
      result = service.fetch_and_save_cards

      if result[:success]
        Rails.logger.info("Cards fetched and saved for user #{id}: #{result[:saved_count]} saved, #{result[:failed_count]} failed")
      else
        Rails.logger.error("Failed to fetch cards for user #{id}: #{result[:error]}")
      end
    rescue StandardError => e
      Rails.logger.error("Error fetching cards for user #{id}: #{e.message}")
    end
  end

  def assign_tag_if_company_56
    return unless company_id == 56
    return unless lotus_token.present?
    return unless start_date.present? && end_date.present?

    begin
      service = TagAssignmentService.new(self, 56)
      result = service.assign_tag

      if result[:success]
        Rails.logger.info("Tag assigned successfully for user #{id}")
      else
        Rails.logger.error("Failed to assign tag for user #{id}: #{result[:error]}")
      end
    rescue StandardError => e
      Rails.logger.error("Error assigning tag for user #{id}: #{e.message}")
    end
  end

  def assign_access_if_company_56
    return unless company_id == 56
    return unless lotus_token.present?

    begin
      service = AccessAssignmentService.new(self, 'user', 56)
      result = service.assign_access

      if result[:success]
        Rails.logger.info("Access assigned successfully for user #{id}")
      else
        Rails.logger.error("Failed to assign access for user #{id}: #{result[:error]}")
      end
    rescue StandardError => e
      Rails.logger.error("Error assigning access for user #{id}: #{e.message}")
    end
  end
end
