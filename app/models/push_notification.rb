require 'net/http'
require 'uri'
require 'json'
require 'googleauth'

class PushNotification
  def self.push_to_devices(devices, sendata)
    Rails.logger.info "------------- devices=#{devices.inspect}, sendata=#{sendata.inspect}"

    # 1) Resolve app_name by host (domain) first, then by company
    host = Rails.application.config.action_mailer.default_url_options[:host] rescue nil

    app_name =  sendata[:company_id].to_i == 48 ? 'CITYAPP' : 'FCMAPP'
#    else
#      {
#        55 => 'HORIZONAPP',
#        56 => 'LOTUSAPP',
#        57 => 'GOYALAPP',
#        61 => 'ARTESIA',
#        45 => 'VIBEAPP'
#      }.fetch(sendata[:company_id].to_i, 'VIBEAPP')
#    end


    Rails.logger.info "[FCM] Starting push_to_devices with app_name=#{app_name}"

    @app = GenericInfo.find_by(company_id: sendata[:company_id], name: app_name)
    unless @app.present?
      Rails.logger.warn "[FCM] GenericInfo not found for company_id=#{sendata[:company_id]} , app_name=#{app_name}"
      return false
    end

    # service_account_file = "#{Rails.root}/#{@app.info_type}.json"
    service_account_file = Rails.root.join("notifics", "#{@app.info_type}.json")
    scope = 'https://www.googleapis.com/auth/firebase.messaging'
    authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: File.open(service_account_file),
      scope: scope
    )
    authorizer.fetch_access_token!
    access_token = authorizer.access_token

    project_id   = @app.info_type
    fcm_endpoint = URI("https://fcm.googleapis.com/v1/projects/#{project_id}/messages:send")
    raw_recipients =
    if devices.respond_to?(:to_a)
      devices.to_a.compact
    else
      Array(devices).compact
    end

    # Deduplicate by FCM token so we don't send the same
    # notification twice when multiple UserDevice rows share
    # the same gcm_key for a user.
    recipients = raw_recipients.uniq do |dv|
      if dv.respond_to?(:gcm_key) && dv.gcm_key.present?
        dv.gcm_key
      else
        dv.object_id
      end
    end

    Rails.logger.info "[FCM] Recipient count: #{recipients.count} (deduped from #{raw_recipients.count})"
    if recipients.empty?
      Rails.logger.warn "[FCM] No devices or topic provided. Aborting push."
      return false
    end

    recipients.each do |dv|
      token = sendata[:topic].present? ? nil : dv.try(:gcm_key)
      if token.blank? && sendata[:topic].blank?
        Rails.logger.warn "[FCM] Skipping device #{dv.inspect} because token and topic are blank."
        next
      end

      Rails.logger.info "[FCM] Sending to: #{token || sendata[:topic]} (#{dv.try(:device_type)})"

      # ---- Build data payload (strings only, control keys removed) ----
      data_payload = build_data_payload(sendata)

      message_payload = { message: {} }
      message         = message_payload[:message]
      message[:data] = data_payload

      # token vs topic
      if sendata[:topic].present?
        message[:topic] = sendata[:topic]
      else
        message[:token] = token
      end

      suppress_notification = !!sendata[:suppress_notification]

      # ---- Notification block (if not suppressed) ----
      unless suppress_notification
        notif_title = sendata[:notification_title] || sendata[:title].to_s
        notif_body  = sendata[:notification_body]  || sendata[:message].to_s

        if notif_title.present? || notif_body.present?
          message[:notification] = {
            title: notif_title,
            body:  notif_body
          }
        end
      end

      # ---- Android config ----
      # Always include android block with high priority (your requirement)
      message[:android] = {
        priority: 'high'
      }

      # ---- iOS / APNS config ----
      aps = {}
      aps['category']            = sendata[:apns_category] if sendata[:apns_category].present?
      aps['interruption-level']  = sendata[:apns_interruption_level] if sendata[:apns_interruption_level].present?
      aps['sound']               = sendata[:apns_sound] if sendata[:apns_sound].present?

      if aps.any?
        message[:apns] = {
          payload: {
            aps: aps
          }
        }
      end

      Rails.logger.info "[FCM] Final payload: #{message_payload.to_json}"
      send_fcm_request(fcm_endpoint, access_token, message_payload, dv)
    end

    Rails.logger.info "[FCM] Completed push_to_devices"
  end

  # Remove control keys and ensure all values are strings for FCM data payload
  def self.build_data_payload(sendata)
    data_payload = sendata.dup

    # Do not include these control keys in "data"
    %i[
      notification_title
      notification_body
      suppress_notification
      apns_category
      apns_interruption_level
      apns_sound
      topic
    ].each { |k| data_payload.delete(k) }

    # Keys as strings, values as strings
    data_payload = data_payload.transform_keys(&:to_s)
    data_payload.each do |k, v|
      data_payload[k] = v.to_s unless v.is_a?(String)
    end

    data_payload
  end
  private_class_method :build_data_payload

  private

  def self.send_fcm_request(fcm_endpoint, access_token, message_payload, dv)
    http = Net::HTTP.new(fcm_endpoint.host, fcm_endpoint.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(
      fcm_endpoint.path,
      'Content-Type'  => 'application/json',
      'Authorization' => "Bearer #{access_token}"
    )
    request.body = message_payload.to_json

    begin
      response = http.request(request)
      Rails.logger.info "[FCM] Response Status: #{response.code} for token #{dv.try(:gcm_key)}"
      Rails.logger.info "[FCM] Response Body: #{response.body}"

      unless response.is_a?(Net::HTTPSuccess)
        body       = JSON.parse(response.body) rescue nil
        error_code = body&.dig('error', 'details', 0, 'errorCode')

        if error_code == 'UNREGISTERED' && dv.respond_to?(:destroy)
          Rails.logger.warn "[FCM] Unregistered token detected, removing: #{dv.gcm_key}"
          dv.destroy
        else
          Rails.logger.error "[FCM] Error sending notification: #{response.body}"
        end
      end
    rescue => e
      Rails.logger.error "[FCM] Exception occurred while sending FCM: #{e.class.name} - #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
    end
  end
end
