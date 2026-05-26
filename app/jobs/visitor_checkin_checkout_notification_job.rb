class VisitorCheckinCheckoutNotificationJob < ApplicationJob
  queue_as :default

  def perform(visitor_id, action_type = 'check_in')
    visitor = Visitor.find_by(id: visitor_id)
    return unless visitor

    Rails.logger.info("Sending #{action_type} notification for Visitor #{visitor_id}")
    company_id = visitor.site&.company_id

    # Determine notification details based on action
    if action_type == 'check_in'
      title = "Visitor In"
      message = "#{visitor.name} entered the complex"
    elsif action_type == 'check_out'
      title = "Visitor Out"
      message = "#{visitor.name} exited the complex"
    else
      return
    end

    # Get all hosts for this visitor
    if visitor.hosts.any?
      visitor.hosts.each do |host|
        next unless host.user_id.present?

        base_sendata = {
          title: title,
          message: message,
          v_name: visitor.name,
          ntype: "visitor",
          action_type: action_type,
          user_id: host.user_id,
          company_id: company_id,
          record_id: visitor.id,
          visitor_id: visitor.id,
          profile_url: visitor.profile_pic&.whole_path.to_s
        }

        Rails.logger.info("Check-in/out notification payload for user #{host.user_id}: #{base_sendata}")

        devices_scope  = UserDevice.where(user_id: host.user_id)
        android_devices = devices_scope.where(device_type: 'android')
        ios_devices     = devices_scope.where(device_type: 'ios')
        other_devices   = devices_scope.where.not(device_type: %w[android ios])

        # ANDROID: data + notification
        if android_devices.exists?
          android_sendata = base_sendata.merge(
            notification_title: title,
            notification_body: message
          )
          Rails.logger.info("Pushing Android notification to #{android_devices.count} devices")
          PushNotification.push_to_devices(android_devices.to_a, android_sendata)
        end

        # IOS: data + notification + APNS category
        if ios_devices.exists?
          ios_sendata = base_sendata.merge(
            notification_title: title,
            notification_body: message,
            apns_category: "FLUTTER_NOTIFICATION_CLICK"
          )
          Rails.logger.info("Pushing iOS notification to #{ios_devices.count} devices")
          PushNotification.push_to_devices(ios_devices.to_a, ios_sendata)
        end

        # Any other device types: generic send
        if other_devices.exists?
          Rails.logger.info("Pushing generic notification to #{other_devices.count} devices")
          PushNotification.push_to_devices(other_devices.to_a, base_sendata)
        end
      end
    end
  end
end
