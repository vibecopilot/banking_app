class QrVerification < ApplicationRecord
  # Associations
  belongs_to :site
  belongs_to :generated_by, class_name: 'User', foreign_key: 'generated_by_id'
  belongs_to :checked_in_by, class_name: 'User', foreign_key: 'checked_in_by_id', optional: true
  belongs_to :checked_out_by, class_name: 'User', foreign_key: 'checked_out_by_id', optional: true
  belongs_to :qr_image, class_name: 'Attachfile', foreign_key: 'qr_image_id', optional: true

  # Virtual attribute for validity in minutes
  attr_accessor :validity_minutes

  # Validations
  validates :code, presence: true, uniqueness: true
  validates :expected_time, presence: true
  validates :valid_till, presence: true
  validates :site_id, presence: true
  validates :generated_by_id, presence: true

  # Scopes
  scope :for_site, ->(site_id) { where(site_id: site_id) }
  scope :active, -> { where(checked_in: false) }
  scope :checked_in, -> { where(checked_in: true) }
  scope :checked_out, -> { where(checked_out: true) }
  scope :currently_present, -> { where(checked_in: true, checked_out: false) }
  scope :valid_now, -> { where('expected_time <= ? AND valid_till >= ?', Time.current, Time.current) }
  scope :expired, -> { where('valid_till < ?', Time.current) }

  # Callbacks
  before_validation :generate_code, on: :create
  before_validation :set_valid_till, on: :create
  after_create :generate_qr_image!

  # Default validity window in minutes
  VALIDITY_WINDOW_MINUTES = 15

  # Generate QR code
  def generate_code
    return if code.present?
    self.code = SecureRandom.urlsafe_base64(32)
  end

  # Set valid_till based on expected_time + validity_minutes
  # Use validity_minutes (virtual attribute) to specify duration in minutes
  def set_valid_till
    return unless expected_time.present?
    
    if validity_minutes.present?
      # validity_minutes is provided (e.g., 15, 30)
      self.valid_till = expected_time + validity_minutes.to_i.minutes
    elsif valid_till.blank?
      # No valid_till or validity_minutes provided, use default 15 minutes
      self.valid_till = expected_time + VALIDITY_WINDOW_MINUTES.minutes
    end
    # Otherwise valid_till is already a datetime, keep as-is
  end

  # Check if QR has expired
  def expired?(at_time = Time.current)
    valid_till < at_time
  end

  # Check if QR is not yet valid (before expected time)
  def not_yet_valid?(at_time = Time.current)
    expected_time > at_time
  end

  # Time remaining until expiry (in seconds)
  def time_remaining(at_time = Time.current)
    return 0 if expired?(at_time)
    (valid_till - at_time).to_i
  end

  # Check if QR is currently valid (within time window)
  def valid_for_checkin?(at_time = Time.current)
    return false if checked_in?
    return false if expired?(at_time)
    return false if not_yet_valid?(at_time)
    true
  end

  # Perform check-in
  def check_in!(user, check_in_at: nil)
    at_time = check_in_at.present? ? check_in_at.to_time : Time.current
    
    return { success: false, error: 'Already checked in' } if checked_in?
    return { success: false, error: 'QR code has expired' } if expired?(at_time)
    return { success: false, error: 'QR code is not yet valid' } if not_yet_valid?(at_time)

    transaction do
      self.checked_in = true
      self.checked_in_at = at_time
      self.checked_in_by = user
      save!
    end

    { success: true, message: 'Check-in successful' }
  rescue => e
    { success: false, error: "Check-in failed: #{e.message}" }
  end

  # Perform check-out
  def check_out!(user, check_out_at: nil)
    at_time = check_out_at.present? ? check_out_at.to_time : Time.current
    
    return { success: false, error: 'Not checked in yet' } unless checked_in?
    return { success: false, error: 'Already checked out' } if checked_out?
    return { success: false, error: 'Check-out time cannot be before check-in time' } if at_time < checked_in_at

    transaction do
      self.checked_out = true
      self.checked_out_at = at_time
      self.checked_out_by = user
      save!
    end

    { success: true, message: 'Check-out successful' }
  rescue => e
    { success: false, error: "Check-out failed: #{e.message}" }
  end

  # QR code data for generating actual QR image
  def qr_data
    {
      code: code,
      expected_time: expected_time.iso8601,
      valid_till: valid_till.iso8601,
      generated_by: generated_by&.full_name,
      purpose: purpose
    }.to_json
  end

  # Generate QR code image and attach it using Attachfile
  def generate_qr_image!
    require 'rqrcode'
    
    qr = RQRCode::QRCode.new(qr_data)
    png = qr.as_png(
      bit_depth: 1,
      border_modules: 4,
      color_mode: ChunkyPNG::COLOR_GRAYSCALE,
      color: 'black',
      file: nil,
      fill: 'white',
      module_px_size: 6,
      resize_exactly_to: false,
      resize_gte_to: false,
      size: 300
    )
    
    # Create a temp file
    temp_file = Tempfile.new(['qr_code', '.png'])
    temp_file.binmode
    temp_file.write(png.to_s)
    temp_file.rewind
    
    # Create Attachfile record with the QR image
    attachfile = Attachfile.create!(
      image: temp_file,
      relation: "QrVerification",
      relation_id: self.id
    )
    
    # Link to this QR verification
    update_column(:qr_image_id, attachfile.id)
    
    temp_file.close
    temp_file.unlink
    
    attachfile
  end

  # Get QR image URL
  # def qr_image_url(host = 'app.myciti.life')
  #   qr_image&.whole_path(host)
  # end

  # Status of the QR code
  def status
    return 'checked_out' if checked_out?
    return 'checked_in' if checked_in?
    return 'expired' if expired?
    return 'pending' if not_yet_valid?
    'valid'
  end
end
