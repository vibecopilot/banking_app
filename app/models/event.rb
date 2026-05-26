class Event < ApplicationRecord
  belongs_to :group, class_name:'Group',foreign_key: :group_id, optional:true
  belongs_to :site
  belongs_to :user ,foreign_key: 'created_by' ,class_name: 'User'
  has_many :event_users, foreign_key: 'event_id'
  has_many :users, through: :event_users
  has_many :event_guests, dependent: :destroy

  # after_create :send_event_notification
  before_create :set_initial_status
  has_one :qr_code, -> { where(relation: 'EventQR') }, class_name: 'Attachfile', foreign_key: 'relation_id'

  def set_initial_status
    self.status = calculate_status
  end

  has_many :attachfiles, -> { where(relation: 'EventImaage') }, class_name: 'Attachfile', foreign_key: 'relation_id'


  def calculate_status
    now = Time.current
    if start_date_time.present? && now < start_date_time
      'upcoming'
    elsif end_date_time.present? && now > end_date_time
      'completed'
    elsif start_date_time.present? && end_date_time.present? && now >= start_date_time && now <= end_date_time
      'ongoing'
    else
      status.presence || 'draft'
    end
  end

  def refresh_status!
    new_status = calculate_status
    update(status: new_status) if status != new_status
  end

  def self.refresh_all_statuses
    where.not(status: 'completed').find_each do |event|
      event.refresh_status!
    end
  end

  include Rails.application.routes.url_helpers

  def create_qr
    require 'rqrcode'
    require 'chunky_png'

    host = Rails.application.config.action_mailer.default_url_options&.dig(:host) ||
      Rails.application.routes.default_url_options[:host] ||
      'localhost'

    port = Rails.application.config.action_mailer.default_url_options&.dig(:port) ||
      Rails.application.routes.default_url_options[:port] ||
      3000

    # Build the check-in URL
    qr_url = Rails.application.routes.url_helpers.check_in_event_url(
      id,
      host: host,
      port: port,
      protocol: 'http'
    )

    Rails.logger.info "Generated QR URL: #{qr_url}"

    qr = RQRCode::QRCode.new(qr_url, size: 10, level: :h)

    png = qr.as_png(
      bit_depth: 1,
      border_modules: 4,
      color_mode: ChunkyPNG::COLOR_GRAYSCALE,
      color: "black",
      file: nil,
      fill: "white",
      module_px_size: 6,
      resize_exactly_to: false,
      resize_gte_to: false,
    )

    # Save PNG to temp file
    file_path = Rails.root.join("tmp", "event_#{id}_qr.png")
    File.binwrite(file_path, png.to_s)

    # Attach to DB
    file = File.open(file_path, "r")
    Attachfile.create(
      image: file,
      relation: "EventQR",
      relation_id: self.id,
      active: 1
    )
    file.close

    # Clean up temp file
    File.delete(file_path) if File.exist?(file_path)
  rescue => e
    Rails.logger.error "QR creation failed: #{e.message}"
    nil
  end

   def send_event_notification
    # binding.pry
    case shared
    when 'individual'

      if event_users.any?
        event_users.each do |event_user|
          EventMailer.event_notification(event_user.user, self).deliver_now if event_user.user.present?
        end
      else
        EventMailer.event_notification(self.user, self).deliver_now if self.user.present?
      end

    when 'group'
      if group_id.present? && group.present?
        group.group_members.include(:user).each do |group_member|
          user = group_member.user
          next unless user.present? && user.email.present?
          EventMailer.event_notification(user, self).deliver_now if user.present?
        end
      end

    when 'all'
      event_users&.each do |event_user|
        EventMailer.event_notification(event_user.user, self).deliver_now if event_user.user.present?
      end
    end
    notify_assigned_to
  end


  private

  def default_url_options
    {
      host: Rails.application.config.action_mailer.default_url_options&.dig(:host) || 'localhost',
      port: Rails.application.config.action_mailer.default_url_options&.dig(:port) || 3000,
      protocol: 'http'
    }
  end

 

  def notify_assigned_to
    if created_by.present? && created_by != 0
      sendata = { title: "Event Created", message: "New Event is Created",  ntype: "event",  user_id: self.created_by,company_id: self.site.company_id, record_id: self.id }
      PushNotification.push_to_devices(UserDevice.where(user_id: created_by), sendata)
    end
  end

end
