require 'net/http'

# Fetches data from Microsoft Graph API on behalf of a user.
# Automatically refreshes expired tokens.
class MicrosoftGraphService
  def initialize(user)
    @user  = user
    @token = user.valid_microsoft_token
  end

  # GET /me — user profile with photo URL
  def profile
    data = get('/me?$select=id,displayName,givenName,surname,mail,userPrincipalName,jobTitle,department,officeLocation')
    return {} if data[:error]

    {
      id:              data['id'],
      email:           data['mail'] || data['userPrincipalName'],
      full_name:       data['displayName'],
      firstname:       data['givenName'],
      lastname:        data['surname'],
      job_title:       data['jobTitle'],
      department:      data['department'],
      office_location: data['officeLocation'],
      photo_url:       "#{MICROSOFT_GRAPH_URL}/me/photo/$value"
    }
  end

  # GET /me/calendarView — meetings for a date range
  # Returns today + next 7 days by default
  def calendar_events(from: Time.current.beginning_of_day, to: 7.days.from_now.end_of_day)
    from_str = from.utc.iso8601
    to_str   = to.utc.iso8601

    data = get("/me/calendarView?startDateTime=#{from_str}&endDateTime=#{to_str}&$select=subject,start,end,location,isOnlineMeeting,onlineMeetingUrl,organizer&$orderby=start/dateTime&$top=50")
    return [] if data[:error] || data['value'].nil?

    data['value'].map do |event|
      {
        id:                 event['id'],
        subject:            event['subject'],
        start:              event.dig('start', 'dateTime'),
        end:                event.dig('end', 'dateTime'),
        timezone:           event.dig('start', 'timeZone'),
        location:           event.dig('location', 'displayName'),
        is_online_meeting:  event['isOnlineMeeting'],
        meeting_url:        event['onlineMeetingUrl'],
        organizer:          event.dig('organizer', 'emailAddress', 'name')
      }
    end
  end

  # GET holidays from the user's holiday calendar
  def holidays(from: Time.current, to: 6.months.from_now)
    # Find the holiday calendar first
    calendars = get('/me/calendars?$select=id,name')
    return [] if calendars[:error] || calendars['value'].nil?

    holiday_cal = calendars['value'].find { |c| c['name'].to_s.downcase.include?('holiday') }
    return [] unless holiday_cal

    from_str = from.utc.iso8601
    to_str   = to.utc.iso8601

    data = get("/me/calendars/#{holiday_cal['id']}/calendarView?startDateTime=#{from_str}&endDateTime=#{to_str}&$select=subject,start,end&$orderby=start/dateTime&$top=30")
    return [] if data[:error] || data['value'].nil?

    data['value'].map do |event|
      {
        name:  event['subject'],
        date:  event.dig('start', 'dateTime'),
        end:   event.dig('end', 'dateTime')
      }
    end
  end

  # GET /me/messages — recent emails with unread count
  def emails(top: 10)
    data = get("/me/messages?$select=subject,from,receivedDateTime,isRead,bodyPreview&$orderby=receivedDateTime desc&$top=#{top}")
    return { unread_count: 0, messages: [] } if data[:error] || data['value'].nil?

    unread = get('/me/mailFolders/inbox?$select=unreadItemCount')
    unread_count = unread[:error] ? 0 : (unread['unreadItemCount'] || 0)

    messages = data['value'].map do |msg|
      {
        id:            msg['id'],
        subject:       msg['subject'],
        from:          msg.dig('from', 'emailAddress', 'name'),
        from_email:    msg.dig('from', 'emailAddress', 'address'),
        received_at:   msg['receivedDateTime'],
        is_read:       msg['isRead'],
        preview:       msg['bodyPreview']&.truncate(120)
      }
    end

    { unread_count: unread_count, messages: messages }
  end

  # GET /me/mailboxSettings — out of office, timezone
  def mailbox_settings
    data = get('/me/mailboxSettings?$select=automaticRepliesSetting,timeZone')
    return {} if data[:error]

    {
      timezone:          data['timeZone'],
      out_of_office:     data.dig('automaticRepliesSetting', 'status') == 'alwaysEnabled' ||
                         data.dig('automaticRepliesSetting', 'status') == 'scheduled',
      out_of_office_msg: data.dig('automaticRepliesSetting', 'internalReplyMessage')
    }
  end

  private

  def get(path)
    uri = URI("#{MICROSOFT_GRAPH_URL}#{path}")
    req = Net::HTTP::Get.new(uri)
    req['Authorization'] = "Bearer #{@token}"
    req['Accept']        = 'application/json'

    res  = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }
    data = JSON.parse(res.body)

    if data['error']
      Rails.logger.error("[Graph] #{path} error: #{data['error']['message']}")
      return { error: data['error']['message'] }
    end

    data
  rescue StandardError => e
    Rails.logger.error("[Graph] #{path} exception: #{e.message}")
    { error: e.message }
  end
end
