class StaffEntryNotificationJob < ApplicationJob
  queue_as :default

  def perform(staff_id, notification_type = 'entry')
    staff = Staff.includes(:units, :site).find_by(id: staff_id)
    
    return unless staff&.units&.any?

    # Get all users associated with staff's units through UserSite
    unit_ids = staff.units.pluck(:id)
    users = User.joins(:user_sites)
                .where(user_sites: { unit_id: unit_ids })
                .includes(:user_devices)
                .distinct
    
    return if users.empty?

    # Get all devices (already preloaded)
    devices = users.flat_map(&:user_devices)
    
    return if devices.empty?

    if notification_type == 'exit'
      sendata = {
        title: "Staff OUT",
        message: "#{staff.full_name} has exited the complex",
        ntype: "staff",
        user_id: nil,
        company_id: staff.site.company_id,
        record_id: staff.id
      }
    else
      sendata = {
        title: "Staff IN",
        message: "#{staff.full_name} has entered the complex",
        ntype: "staff",
        user_id: nil,
        company_id: staff.site.company_id,
        record_id: staff.id
      }
    end
    
    PushNotification.push_to_devices(devices, sendata)
  end
end
