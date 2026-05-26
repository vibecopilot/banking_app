class AmenityBooking < ApplicationRecord
  belongs_to :amenity, optional: true
  belongs_to :amenity_slot, optional: true
  belongs_to :amenity_setup, optional: true
  has_many :amenity_notifications, dependent: :destroy
  has_one :payment, -> { where(resource_type: "AmenityBooking") }, class_name: "Payment", foreign_key: :resource_id
  belongs_to :user, class_name: "User", foreign_key: :user_id

  after_create :send_booking_notification
  after_create :notify_admins_on_create
  after_update :notify_admins_on_status_change
  after_destroy :notify_admins_on_destroy

  # --- existing methods left as-is ---
  def send_booking_notification
    type_of_facility = amenity&.is_hotel ? "HotelBooking" : "FacilityBooking"
    sendata = {
      title: "New #{type_of_facility} Created",
      message: "Booking for #{amenity&.fac_name} on #{booking_date} is Created",
      created_by: user.try(:full_name),
      ntype: "facilitybooking",
      company_id: user&.site&.company_id,
      record_id: id
    }
    PushNotification.push_to_devices(UserDevice.where(user_id: user_id), sendata)
  end

   ransacker :search do |parent|
   Arel.sql(
    "CONCAT_WS(' ',
        amenity_bookings.id,
        amenity_bookings.payment_mode,
        amenity_bookings.status,
        amenity_bookings.amount,
        amenity_bookings.booking_date,
        amenities.fac_name,
        amenities.fac_type,
        users.firstname,
        users.lastname
      )"
    )
  end

  private

  # --- slot check (unchanged) ---
  def slot_is_in_the_future
    return unless amenity_slot
    current_hour = Time.current.hour
    slot_hour = amenity_slot.start_hr

    if slot_hour >= current_hour
      Rails.logger.info "✅ Slot is available for booking."
    else
      errors.add(:amenity_slot, "must be a future slot.")
    end
  end

  # --- admin notification helpers ---

  # Find pms_admin users for the booking's site
  def site_admins
    site_id = user&.current_site_id || user&.site_id
    return User.none unless site_id

    # Find all pms_admin users for this site via user_sites association
    User.joins(:user_sites)
        .where(user_sites: { site_id: site_id })
        .where(user_type: 'pms_admin')
        .distinct
  end

  def notify_admins(payload)
    admins = site_admins
    return if admins.blank?

    # Build device query; PushNotification helper expects user devices
    PushNotification.push_to_devices(UserDevice.where(user_id: admins.pluck(:id)), payload)
  end

  # Notify on create
  def notify_admins_on_create
    type_of_facility = amenity&.is_hotel ? "HotelBooking" : "FacilityBooking"
    payload = {
      title: "New #{type_of_facility} Created",
      message: "Booking by #{user.try(:full_name)} for #{amenity&.fac_name} on #{booking_date} was created",
      created_by: user.try(:full_name),
      ntype: "facilitybooking",
      company_id: user&.site&.company_id,
      record_id: id
    }
    notify_admins(payload)
  end

  # Notify when status changes to a cancelled state
  def notify_admins_on_status_change
    # Use saved_change_to_status? for Rails 5.1+; fallback for older rails: status_changed? / saved_changes
    if respond_to?(:saved_change_to_status?)
      changed_to = saved_change_to_status&.last
      changed_from = saved_change_to_status&.first
    elsif respond_to?(:status_changed?)
      # deprecated API fallback
      changed_to = status
      changed_from = status_was
    else
      changed_to = nil
      changed_from = nil
    end

    # Notify admins on any status change
    if changed_to.present? && changed_to != changed_from
      type_of_facility = amenity&.is_hotel ? "Hotel Booking" : "Facility Booking"
      
      payload = {
        title: "#{type_of_facility} Status Updated",
        message: "Booking by #{user.try(:full_name)} for #{amenity&.fac_name} on #{booking_date} status changed to #{changed_to}",
        updated_by: user.try(:full_name),
        ntype: "facilitybooking",
        company_id: user&.site&.company_id,
        record_id: id
      }
      notify_admins(payload)
    end
  end

  # Optional: notify admins when a booking is destroyed
  def notify_admins_on_destroy
    payload = {
      title: "Booking Removed",
      message: "Booking by #{user.try(:full_name)} for #{amenity&.fac_name} on #{booking_date} was removed",
      ntype: "facilitybooking",
      company_id: user&.site&.company_id,
      record_id: id
    }
    notify_admins(payload)
  end
end
