class VisitorOverstayAlertJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info "[VisitorOverstayAlert] Starting overstay check at #{Time.current}"

    # Get all enabled alert configurations
    VisitorAlertConfig.where(enabled: true).find_each do |config|
      check_overstaying_visitors(config)
    end

    Rails.logger.info "[VisitorOverstayAlert] Completed overstay check at #{Time.current}"
  end

  private

  def check_overstaying_visitors(config)
    site = Site.find_by(id: config.site_id)
    return unless site

    Rails.logger.info "[VisitorOverstayAlert] Checking site: #{site.name} (ID: #{site.id})"

    # Find all visitors who are currently checked in (IN status)
    # and whose last check-in exceeds the threshold
    overstaying_visitors = Visitor
      .joins(:visitor_visits)
      .where(site_id: config.site_id, visitor_in_out: 'IN')
      .where('visitor_visits.check_in IS NOT NULL')
      .where('visitor_visits.check_out IS NULL')
      .select('visitors.*, visitor_visits.check_in, visitor_visits.id as visit_id')
      .distinct

    overstaying_visitors.each do |visitor|
      # Get the most recent check-in for this visitor
      latest_visit = VisitorVisit
        .where(visitor_id: visitor.id)
        .where.not(check_in: nil)
        .where(check_out: nil)
        .order(check_in: :desc)
        .first

      next unless latest_visit

      # Check if visitor has overstayed
      if config.visitor_overstayed?(latest_visit.check_in)
        send_overstay_alert(visitor, latest_visit, config)
      end
    end
  end

  def send_overstay_alert(visitor, visit, config)
    check_in_time = visit.check_in
    duration = calculate_duration(check_in_time)
    
    Rails.logger.info "[VisitorOverstayAlert] Visitor #{visitor.name} (ID: #{visitor.id}) has overstayed. Duration: #{duration}"

    # Send notification to hosts
    visitor.hosts.each do |host|
      send_notification_to_host(host, visitor, duration, config)
    end

    # Send notification to security guards at this site
    send_notification_to_security(visitor, duration, config)
  end

  def send_notification_to_host(host, visitor, duration, config)
    sendata = {
      title: "Visitor Overstay Alert",
      message: "Visitor #{visitor.name} has been on premises for #{duration}. Please check if they need assistance or have completed their visit.",
      profile_url: visitor.profile_pic&.whole_path,
      v_name: visitor.name,
      purpose: visitor.purpose,
      ntype: "visitor_overstay",
      user_id: host.user_id,
      company_id: visitor.site.company_id,
      record_id: visitor.id,
      duration: duration
    }

    PushNotification.push_to_devices(
      UserDevice.where(user_id: host.user_id),
      sendata
    )

    Rails.logger.info "[VisitorOverstayAlert] Sent alert to host: #{host.user_id}"
  end

  def send_notification_to_security(visitor, duration, config)
    # Find all security guards for this site
    security_guards = User
      .where(user_type: 'security_guard', current_site_id: config.site_id)
      .pluck(:id)

    return if security_guards.empty?

    sendata = {
      title: "Visitor Overstay Alert",
      message: "Visitor #{visitor.name} has been on premises for #{duration}. Purpose: #{visitor.purpose}",
      profile_url: visitor.profile_pic&.whole_path,
      v_name: visitor.name,
      purpose: visitor.purpose,
      ntype: "Security_Visit",
      company_id: visitor.site.company_id,
      record_id: visitor.id,
      duration: duration
    }

    security_guards.each do |guard_id|
      sendata[:user_id] = guard_id
      PushNotification.push_to_devices(
        UserDevice.where(user_id: guard_id),
        sendata
      )
    end

    Rails.logger.info "[VisitorOverstayAlert] Sent alert to #{security_guards.count} security guards"
  end

  def calculate_duration(check_in_time)
    seconds = Time.current - check_in_time
    hours = (seconds / 3600).floor
    minutes = ((seconds % 3600) / 60).floor

    if hours > 0
      "#{hours} hour#{hours > 1 ? 's' : ''} #{minutes} minute#{minutes > 1 ? 's' : ''}"
    else
      "#{minutes} minute#{minutes > 1 ? 's' : ''}"
    end
  end
end
