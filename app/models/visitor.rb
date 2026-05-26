require 'rqrcode'
require 'chunky_png'
require 'digest'
class Visitor < ApplicationRecord
  has_many :hosts
  has_many :visitor_cards, dependent: :destroy
  belongs_to :parking_configuration, foreign_key: 'parking_slot', class_name: 'ParkingConfiguration', primary_key: 'id', optional: true
  belongs_to :visitor_staff_category, class_name: 'GenericSubInfo', foreign_key: 'visitor_staff_category_id', optional: true
  has_many :visitor_files, -> { where(relation: "VisitorFile") }, foreign_key: :relation_id, class_name: "Attachfile"
  has_many :visitor_license, -> { where(relation: "VisitorLicense") }, foreign_key: :relation_id, class_name: "Attachfile"
  has_many :visitor_consignment, -> { where(relation: "VisitorConsignment") }, foreign_key: :relation_id, class_name: "Attachfile"
  has_one :profile_pic, -> { where(relation: "VisitorProfilePic") }, foreign_key: :relation_id, class_name: "Attachfile", dependent: :destroy
  has_one :goods_in_out
  belongs_to :visitor_category, optional: true
  belongs_to :visitor_sub_category, optional: true
  # validates :name, :site_id, presence: true
  # validates :otp, length: { is: 5 }, allow_nil: true
  # validates :contact_no, length: { is: 10 }, numericality: { only_integer: true }
  has_many :extra_visitors, dependent: :destroy
  accepts_nested_attributes_for :extra_visitors, allow_destroy: true
  belongs_to :site
  belongs_to :created_by, class_name: 'User', foreign_key: 'created_by_id', optional: true
  has_one :host, dependent: :destroy
  has_many :visitor_visits, dependent: :destroy
  before_save :set_end_pass_time_for_once_frequency
  after_create :create_qr  #, unless: :use_secure_qr?
  after_create :sync_to_external_api_if_company_56
  after_create :assign_access_if_company_56
  after_create :fetch_cards_if_company_56
  after_create :assign_tag_if_company_56
  #after_create :create_secure_qr, if: :use_secure_qr?
  has_one :qr_code_image, -> { where(relation: "VisitorQR") }, foreign_key: :relation_id, class_name: "Attachfile"
  #has_one :qr_code_image, -> { where(relation: "VisitorSecureQR") }, foreign_key: :relation_id, class_name: "Attachfile"
  serialize :working_days, Array
  before_create :generate_and_store_otp
  before_save :update_status

  def self.ransackable_associations(_auth_object = nil)
    %w[created_by]
  end

  ransacker :user_type do
    Arel.sql('users.user_type')

  end

  def self.update_expired_passes
    where("end_pass < ? AND status = ?", Time.current, true)
    .update_all(status: false)
  end

  ransacker :search do |parent|
    Arel.sql(
      "CONCAT_WS(' ',
        visitors.id,
        visitors.visit_type,
        visitors.name,
        visitors.contact_no,
        visitors.purpose,
        visitors.vehicle_number,
        users.firstname,
        users.lastname
      )"
    )
  end

  def create_qr
    qr_code = RQRCode::QRCode.new("#{self.try(:id)}", self.id, size: 10, :level => :h)
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
    png.save("tmp/#{self.id}.png")
    file = File.open("tmp/#{self.id}.png", "r")
    Attachfile.create(image: file, relation: "VisitorQR", relation_id: self.id, active: 1)
  end

  # New secure QR flow (keeps existing create_qr intact)
  # Encodes visitor_id + token in QR payload. Validation is done via token digest.
  # def create_secure_qr
  #   token = generate_qr_token
  #   digest = self.class.qr_digest(token)
  #   minutes = normalized_qr_pending_expiry_minutes

  #   # Avoid recursive callbacks; we only need to persist timestamps/digest.
  #   update_columns(
  #     qr_token_digest: digest,
  #     qr_generated_at: Time.current,
  #     qr_pending_expiry_minutes: minutes
  #   )

  #   payload = "v=#{id}&t=#{token}"
  #   qr_code = RQRCode::QRCode.new(payload, size: 10, level: :h)
  #   png = qr_code.as_png(
  #     resize_gte_to: false,
  #     resize_exactly_to: false,
  #     fill: 'white',
  #     color: 'black',
  #     size: 200,
  #     border_modules: 4,
  #     module_px_size: 6,
  #     file: nil
  #   )

  #   file_path = Rails.root.join('tmp', "visitor_secure_qr_#{id}.png")
  #   png.save(file_path.to_s)
  #   file = File.open(file_path, 'r')
  #   Attachfile.create(image: file, relation: 'VisitorSecureQR', relation_id: id, active: 1)
  # ensure
  #   file&.close
  # end

  def self.qr_digest(token)
    Digest::SHA256.hexdigest(token.to_s)
  end

  def qr_token_valid?(token)
    return false if qr_token_digest.blank? || token.blank?
    # Support both: raw token (hash it) or direct digest comparison (legacy QRs)
    # First try direct comparison (if QR payload contains digest)
    return true if ActiveSupport::SecurityUtils.secure_compare(qr_token_digest, token.to_s)
    # Then try hashing (if QR payload contains raw token)
    expected = self.class.qr_digest(token)
    ActiveSupport::SecurityUtils.secure_compare(qr_token_digest, expected)
  rescue StandardError
    false
  end

  # Expiry rule:
  # - QR is ONLY valid between expected_date+expected_time and expected_date+expected_time+qr_pending_expiry_minutes
  # - Before expected_time: QR not yet valid
  # - After expiry: QR expired
  # - If checked-in: QR stays valid for 1 day from expected visit time (for checkout)
  # @param token [String] the QR token to validate
  # @param at_time [Time] optional - the time to validate against (default: Time.current)
  def qr_valid_now?(token, at_time: nil)
    return false unless qr_token_valid?(token)
    expiry_base = qr_expiry_base_time
    return false if expiry_base.blank?

    check_time = at_time || Time.current

    # Check if check_time is BEFORE the valid window starts
    return false if check_time < expiry_base

    if qr_checked_in_at.present?
      # After check-in, valid for 1 day for checkout
      check_time <= (expiry_base + 1.day)
    else
      # Before check-in, only valid within the expiry window
      check_time <= (expiry_base + normalized_qr_pending_expiry_minutes.minutes)
    end
  end

  # Check if QR is not yet valid (before expected time)
  # @param at_time [Time] optional - the time to check against (default: Time.current)
  def qr_not_yet_valid?(at_time: nil)
    expiry_base = qr_expiry_base_time
    return false if expiry_base.blank?
    check_time = at_time || Time.current
    check_time < expiry_base
  end

  # Check if QR is expired
  # @param at_time [Time] optional - the time to check against (default: Time.current)
  def qr_expired?(at_time: nil)
    expiry_time = qr_expires_at
    return false if expiry_time.blank?
    check_time = at_time || Time.current
    check_time > expiry_time
  end

  # Calculate the base time for QR expiry from expected_date + expected_time
  def qr_expiry_base_time
    return qr_generated_at if expected_date.blank? || expected_time.blank?

    # Combine expected_date and expected_time
    date = expected_date.is_a?(Date) ? expected_date : Date.parse(expected_date.to_s)
    time = expected_time.is_a?(Time) ? expected_time : Time.parse(expected_time.to_s)

    Time.zone.local(date.year, date.month, date.day, time.hour, time.min, time.sec)
  rescue
    qr_generated_at
  end

  # Calculate the exact QR expiry time
  def qr_expires_at
    base = qr_expiry_base_time
    return nil if base.blank?
    base + normalized_qr_pending_expiry_minutes.minutes
  end

  def mark_qr_checked_in!(check_in_time = nil)
    return if qr_checked_in_at.present?
    update_columns(qr_checked_in_at: check_in_time || Time.current)
  end

  def verify_otp(input_otp)
    return false unless otp.present? && otp == input_otp
    # OTP is valid, perform additional actions if needed# OTP is valid, mark visitor as verified
    update(otp: nil, verified: true) # Optionally clear the OTP after verification
    true
  end

  def self.clear_expired_otps
    Visitor.where("otp IS NOT NULL").where("created_at < ?", 12.hours.ago).update_all(otp: nil)
  end

  private

  # def use_secure_qr?
  #   qr_pending_expiry_minutes.present?
  # end

  def set_end_pass_time_for_once_frequency
    if self.frequency == 'Once' && self.start_pass.present?
      self.end_pass = self.start_pass + 24.hours
    end
  end

  def update_status
    self.status = (end_pass.nil? || end_pass > Time.current) if end_pass_changed? || new_record?
  end

  def normalized_qr_pending_expiry_minutes
    minutes = qr_pending_expiry_minutes.presence || 15
    minutes = minutes.to_i
    # Hard clamp to a safe range (frontend decides 15/30; we allow 1..180)
    minutes = 15 if minutes <= 0
    [minutes, 180].min
  end

  def generate_qr_token
    SecureRandom.urlsafe_base64(32)
  end

  def generate_and_store_otp
    self.otp = generate_unique_otp
    stored_otps(self.otp)
  end

  def generate_unique_otp
    otp_file = Rails.root.join('otp.txt')
    existing_otps = File.exist?(otp_file) ? File.readlines(otp_file).map(&:strip) : []
    otp = nil
    loop do
      otp = SecureRandom.random_number(100000..999999).to_s
      break unless existing_otps.include?(otp)
    end
    otp
  end

  def stored_otps(otp)
    File.open(Rails.root.join('otp.txt'), 'a') { |f| f.puts otp }
  end

  # Optional: Define a helper method to include the created_by user's name
  def created_by_name
    created_by&.fullname
  end

  def sync_to_external_api_if_company_56
    return unless site&.company_id == 56
    return unless lotus_token.present?

    begin
      service = VisitorExternalSyncService.new(self, 56)
      result = service.sync

      if result[:success]
        Rails.logger.info("Visitor #{id} synced to external API successfully")
      else
        Rails.logger.error("Failed to sync visitor #{id} to external API: #{result[:error]}")
      end
    rescue StandardError => e
      Rails.logger.error("Error syncing visitor #{id} to external API: #{e.message}")
    end
  end

  def assign_access_if_company_56
    return unless site&.company_id == 56
    return unless lotus_token.present?

    begin
      service = AccessAssignmentService.new(self, 'visitor', 56)
      result = service.assign_access

      if result[:success]
        Rails.logger.info("Access assigned successfully for visitor #{id}")
      else
        Rails.logger.error("Failed to assign access for visitor #{id}: #{result[:error]}")
      end
    rescue StandardError => e
      Rails.logger.error("Error assigning access for visitor #{id}: #{e.message}")
    end
  end

  def fetch_cards_if_company_56
    return unless site&.company_id == 56
    return unless lotus_token.present?

    begin
      service = VisitorCardInventoryService.new(self, 56)
      result = service.fetch_and_save_cards

      if result[:success]
        Rails.logger.info("Cards fetched and saved for visitor #{id}: #{result[:saved_count]} saved, #{result[:failed_count]} failed")
      else
        Rails.logger.error("Failed to fetch cards for visitor #{id}: #{result[:error]}")
      end
    rescue StandardError => e
      Rails.logger.error("Error fetching cards for visitor #{id}: #{e.message}")
    end
  end

  def assign_tag_if_company_56
    return unless site&.company_id == 56
    return unless lotus_token.present?

    begin
      service = VisitorTagAssignmentService.new(self, 56)
      result = service.assign_tag

      if result[:success]
        Rails.logger.info("Tag assigned successfully for visitor #{id}")
      else
        Rails.logger.error("Failed to assign tag for visitor #{id}: #{result[:error]}")
      end
    rescue StandardError => e
      Rails.logger.error("Error assigning tag for visitor #{id}: #{e.message}")
    end
  end
end
