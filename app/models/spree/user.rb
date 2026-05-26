require "telephone_number"
class Spree::User < ApplicationRecord
  self.table_name = 'users'
  # devise :omniauthable, omniauth_providers: %i[saml]
  # devise :authentication_keys => [:mobile, :email, :org_user_id]
  # has_one :lock_user_permission, class_name: "User"

  validates_numericality_of :mobile, if: proc { mobile.present? }
  validates :firstname, :presence => true
  validates :lastname, :presence => true
  validates_uniqueness_of :email, :scope => [:mobile, :org_user_id, :organization_id], allow_blank: true
  validates_uniqueness_of :mobile, if: proc { mobile.present? } #, :format => { :with => /\A(\+1)?[0-9]{10}\z/, :message => "Not a valid 10-digit mobile number" }
  # validates_uniqueness_of :email, :presence => true
  # validates :mobile, telephone_number: {country: proc{|record| :in }, types: [ :mobile ]}
  after_create :set_user_role
  after_save :send_otp_email
  after_update :update_log, if: proc{|a| a.saved_change_to_firstname? || a.saved_change_to_lastname? || a.saved_change_to_email? || a.saved_change_to_mobile?}

  #after_update :update_organization_admin

  has_many :user_devices
  has_many :complaints, :foreign_key => :id_user
  belongs_to :role
  has_many :lock_roles

  # User Roles associations

  has_attached_file :avatar, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "/images/profile.png"
  validates_attachment_content_type :avatar, content_type: %w(/\Aimage\/.*\Z/ application/octet-stream image/jpeg image/jpg image/png)

  alias_attribute :id_user, :id


  unique_sku_filter = _validate_callbacks.find do |c|
    c.filter.is_a?(ActiveRecord::Validations::UniquenessValidator) &&
      c.filter.instance_variable_get(:@attributes) == [:email]
  end.filter

  skip_callback(:validate, unique_sku_filter)

  def user
    self
  end

  def lock_user_permission
    self
  end

  def self.current
    Thread.current[:current_user]
  end

  def staff_user
    self
  end

  def username
    full_name
  end

  def name_chunk
    charset = ("a".."z").to_a - %w(b i l o s) + ("2".."9").to_a - %w(5 8)
    chunk = username.parameterize[0...3]
    if chunk.empty?
      chunk + (0...3).map { charset.to_a[rand(charset.size)] }.join
    elsif chunk.length == 1
      chunk + (0...2).map { charset.to_a[rand(charset.size)] }.join
    elsif chunk.length == 2
      chunk + (0...1).map { charset.to_a[rand(charset.size)] }.join
    else
      chunk
    end
  end

  def self.current=(usr)
    Thread.current[:current_user] = usr
  end

  def self.current_acnt
    Thread.current[:current_acnt]
  end

  def self.current_acnt=(acnt)
    Thread.current[:current_acnt] = acnt
  end


  def self.allowed_societies
    Thread.current[:allowed_societies]
  end

  def self.allowed_societies=(ascs)
    Thread.current[:allowed_societies] = ascs
  end

  def self.allowed_sites
    Thread.current[:allowed_sites]
  end

  def self.allowed_sites=(sites)
    Thread.current[:allowed_sites] = sites
  end


  def full_name
    if firstname
      firstname.try(:+, " ").try(:+, lastname)
    else
      lastname
    end
  end

  # This method check user role
  def has_role?(role)
    if role_id.present?
      Role.find_by_id(role_id).try(:name) == role
    end
  end

  # Set user role to normal after create
  def set_user_role
    self.generate_api_key!
    if self.role_id.blank?
      role_id = Role.find_by_name('normal_user').try(:id)
      if role_id
        self.role_id = role_id
        self.save!
      end
    end
  end

  def send_otp_email
    if saved_change_to_mobile? && otp.present?
      UserMailer.send_otp_mail(self).deliver_now
    end
  end

  def utype
    if self.user_type == "pms_admin"
      "Admin"
    elsif self.user_type == "pms_hse"
      "Head Site Engineer"
    elsif self.user_type == "pms_se"
      "Site Engineer"
    elsif self.user_type == "pms_accounts"
      "Accounts"
    elsif self.user_type == "pms_po"
      "Purchase Officer"
    elsif self.user_type == "pms_qc"
      "Quality Control"
    elsif self.user_type == "pms_technician"
      "Technician"
    elsif self.user_type == "pms_security"
      'Security'
    elsif self.user_type == "pms_security_supervisor"
      'Security Supervisor'
    elsif self.user_type == "pms_occupant"
      'User'
    elsif self.user_type == "pms_occupant_admin"
      'Admin'
    elsif self.user_type == "pms_organization_admin"
      'Org. Admin'
    end
  end

  def user_type_name
    if %w(pms_admin pms_technician).include?(self.user_type)
      'FM User'
    elsif %w(pms_occupant pms_occupant_admin).include?(self.user_type)
      'Occupant'
    end
  end

  def pms_occupant_admin?
    self.user_type == 'pms_occupant_admin'
  end

  def pms_occupant_user?
    self.user_type == 'pms_occupant'
  end

  def pms_occupant?
    %w(pms_occupant pms_occupant_admin).include?(self.user_type)
  end

  def pms_accounts?
    %w(pms_accounts pms_hse pms_se pms_po pms_qc).include?(self.user_type)
  end

  def pms_organization_admin?
    self.user_type == 'pms_organization_admin'
  end

  def pms_admin?
    %w(pms_admin pms_organization_admin).include?(self.user_type)
  end

  def send_registration_notification(password=nil, current_user=nil)

  end

  def update_log
    SystemLog.newlog(self, "User updated", self.saved_changes.present? ? self.saved_changes : nil , self)
  end
end
