class VisitorNotificationJob < ApplicationJob
  queue_as :default

  def perform(visitor_id, event_type = 'create')
    visitor = Visitor.find_by(id: visitor_id)
    return unless visitor && visitor.skip_host_approval != true

    Rails.logger.info("Sending notifications for Visitor #{visitor_id}, event: #{event_type}")
    company_id = visitor.site&.company_id
    notified_user_ids = []

    if event_type.in?(["create", "reminder"])
      # ==== HOST NOTIFICATIONS ====
      if visitor.hosts.any?
        visitor.hosts.each do |host|
          next unless host.user_id.present?

          # Avoid sending multiple times to same user in this job
          if notified_user_ids.include?(host.user_id)
            Rails.logger.info("Skipping host #{host.user_id} – already notified")
            next
          end

          creator = visitor.created_by
          creator_is_security = creator&.user_type == "security_guard"
          ntype = creator_is_security ? "Security_Visit" : "visitor"

          base_sendata = {
            title:       "Visitor Created",
            profile_url: visitor.profile_pic&.whole_path.to_s,
            message:     "New Visitor: #{visitor.name} for purpose #{visitor.purpose} is Created",
            v_name:      visitor.name,
            purpose:     visitor.purpose,
            ntype:       ntype,
            user_id:     host.user_id,
            company_id:  company_id,
            record_id:   visitor.id
          }

          Rails.logger.info("Host notification payload for user #{host.user_id}: #{base_sendata}")

          devices_scope  = UserDevice.where(user_id: host.user_id)
          android_devices = devices_scope.where(device_type: 'android')
          ios_devices     = devices_scope.where(device_type: 'ios')
          other_devices   = devices_scope.where.not(device_type: %w[android ios])

          if creator_is_security
            # --- Security guard created visitor ---
            # Split by full_screen flag per device
            android_fs_true  = android_devices.where(full_screen: true)
            android_fs_false = android_devices.where('full_screen IS NULL OR full_screen = ?', false)
            ios_fs_true      = ios_devices.where(full_screen: true)
            ios_fs_false     = ios_devices.where('full_screen IS NULL OR full_screen = ?', false)

            Rails.logger.info "Security creator: devices for host #{host.user_id} -> " \
                              "android_fs_true=#{android_fs_true.count}, android_fs_false=#{android_fs_false.count}, " \
                              "ios_fs_true=#{ios_fs_true.count}, ios_fs_false=#{ios_fs_false.count}, other=#{other_devices.count}"

            # ANDROID full_screen=true: data-only, ntype = Security_Visit (current behavior)
            if android_fs_true.exists?
              Rails.logger.info "Pushing SECURITY Android (full_screen=true, data-only) to #{android_fs_true.count} devices"
              PushNotification.push_to_devices(
                android_fs_true.to_a,
                base_sendata.merge(suppress_notification: true) # no notification block
              )
            end

            # ANDROID full_screen=false/nil: ntype=visitor + basic notification
            if android_fs_false.exists?
              android_sendata = base_sendata.merge(
                ntype:              "visitor",
                notification_title:  "New Visitor",
                notification_body:   "New Visitor",
                suppress_notification: false
              )
              Rails.logger.info "Pushing SECURITY Android (full_screen=false) to #{android_fs_false.count} devices"
              PushNotification.push_to_devices(android_fs_false.to_a, android_sendata)
            end

            # IOS full_screen=true: ntype=visitor + time-sensitive sound (current behavior)
            if ios_fs_true.exists?
              ios_sendata = base_sendata.merge(
                ntype:                   "visitor",
                notification_title:      base_sendata[:title],
                notification_body:       base_sendata[:message],
                apns_interruption_level: "time-sensitive",
                # apns_sound:              "cellphone_ring.wav"
                # apns_sound:              devices_scope.ios_sound || "audio_default.wav"
                apns_sound:              "audio_default.wav"
              )
              Rails.logger.info "Pushing SECURITY iOS (full_screen=true, time-sensitive) to #{ios_fs_true.count} devices"
              PushNotification.push_to_devices(ios_fs_true.to_a, ios_sendata)
            end

            # IOS full_screen=false/nil: ntype=visitor + basic notification
            if ios_fs_false.exists?
              ios_basic_sendata = base_sendata.merge(
                ntype:             "visitor",
                notification_title: "New Visitor",
                notification_body:  "New Visitor"
              )
              Rails.logger.info "Pushing SECURITY iOS (full_screen=false) to #{ios_fs_false.count} devices"
              PushNotification.push_to_devices(ios_fs_false.to_a, ios_basic_sendata)
            end
          else
            # --- Normal user created visitor ---
            # ANDROID: data + notification + android.priority=high (set in PushNotification)
            if android_devices.exists?
              android_sendata = base_sendata.merge(
                notification_title: (base_sendata[:title] || "New Visitor"),
                notification_body:  (base_sendata[:message]  || "New Visitor")
              )
              PushNotification.push_to_devices(android_devices.to_a, android_sendata)
            end

            # IOS: data + notification + APNS category
            if ios_devices.exists?
              ios_title = base_sendata[:notification_title] || base_sendata[:title]
              ios_body  = base_sendata[:notification_body]  || base_sendata[:message]
              ios_sendata = base_sendata.merge(
                notification_title: ios_title,
                notification_body:  ios_body,
                apns_category:      "FLUTTER_NOTIFICATION_CLICK"
              )
              PushNotification.push_to_devices(ios_devices.to_a, ios_sendata)
            end
          end

          # Any other device types: generic send
          if other_devices.exists?
            PushNotification.push_to_devices(other_devices.to_a, base_sendata)
          end

          # mark this user as already notified
          notified_user_ids << host.user_id
        end
      end

      # ==== CREATOR NOTIFICATION ====
      # Notify creator (if security guard or other creator)
      if visitor.created_by_id.present? && visitor.created_by_id != 0
        creator = visitor.created_by
        # Skip if security_guard (already covered in host flow) or already notified
        if creator&.user_type == "security_guard" || notified_user_ids.include?(creator.id)
          Rails.logger.info("Skipping creator #{creator&.id} – security_guard or already notified")
        else
          # Creator (non-security) should always receive a normal visitor notification
          ntype = "visitor"

          base_sendata = {
            title: "Visitor Created",
            profile_url: visitor.profile_pic&.whole_path,
            message: "New Visitor: #{visitor.name} for purpose #{visitor.purpose} is Created",
            v_name: visitor.name,
            purpose: visitor.purpose,
            ntype: ntype,
            user_id: visitor.created_by_id,
            company_id: company_id,
            record_id: visitor.id
          }

          devices_scope = UserDevice.where(user_id: visitor.created_by_id)
          android_devices = devices_scope.where(device_type: 'android')
          ios_devices     = devices_scope.where(device_type: 'ios')
          other_devices   = devices_scope.where.not(device_type: %w[android ios])

          if android_devices.exists?
            Rails.logger.info("Creator Android notification payload: #{base_sendata}")
            PushNotification.push_to_devices(android_devices, base_sendata)
          end

          if ios_devices.exists?
            ios_title = base_sendata[:notification_title] || base_sendata[:title]
            ios_body  = base_sendata[:notification_body]  || base_sendata[:message]

            ios_sendata = base_sendata.merge(
              notification_title: ios_title,
              notification_body:  ios_body,
              apns_category:      "FLUTTER_NOTIFICATION_CLICK"
            )
            Rails.logger.info("Creator iOS notification payload: #{ios_sendata}")
            PushNotification.push_to_devices(ios_devices, ios_sendata)
          end

          if other_devices.exists?
            Rails.logger.info("Creator generic notification payload: #{base_sendata}")
            PushNotification.push_to_devices(other_devices, base_sendata)
          end

          notified_user_ids << creator.id
        end
      end
      
      # Notify site admins
      # if visitor.site_id.present?
      #   admin_user_ids = UserSite.where(site_id: visitor.site_id).pluck(:user_id)
      #   admin_user_ids = User.where(id: admin_user_ids, user_type: ["pms_admin"]).pluck(:id)
      #   # remove already-notified users (host/creator)
      #   admin_user_ids -= notified_user_ids
        
      #   if admin_user_ids.any?
      #     admin_sendata = {
      #       title: "New Visitor",
      #       message: "New visitor #{visitor.name} has been registered",
      #       ntype: "visitor",
      #       visitor_id: visitor.id,
      #       company_id: company_id,
      #       record_id: visitor.id
      #     }
          
      #     Rails.logger.info("Admin notification for #{admin_user_ids.count} users: #{admin_sendata}")
      #     PushNotification.push_to_devices(UserDevice.where(user_id: admin_user_ids), admin_sendata)
      #   end
      # end
    end
  end
end