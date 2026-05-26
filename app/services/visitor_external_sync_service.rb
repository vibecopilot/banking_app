class VisitorExternalSyncService
  BASE_URL = 'http://103.76.77.112:8090/api/user/createOrUpdate'

  def initialize(visitor, company_id = 56)
    @visitor = visitor
    @company_id = company_id
  end

  def sync
    return { success: false, error: 'Visitor not found' } unless @visitor.present?
    return { success: false, error: 'lotus_token is missing for this visitor' } unless @visitor.lotus_token.present?

    payload = build_payload
    Rails.logger.info("Visitor External Sync Payload for Visitor #{@visitor.id}: #{payload.to_json}")
    send_request(payload)
  end

  private

  def build_payload
    host_name = @visitor.hosts.first&.user&.full_name || ''
    
    {
      company_code: '01',
      location_code: 'MUM',
      usertype: 'vms',
      code: @visitor.id.to_s,
      name: @visitor.name,
      emailId: 'abcd1212@vibe.com',
      mobile: @visitor.contact_no || '',
      hierarchyName: host_name,
      reportingManager: ''
    }
  end

  def send_request(payload)
    uri = URI(BASE_URL)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.path, headers)
    request.body = payload.to_json

    begin
      response = http.request(request)
      parse_response(response)
    rescue StandardError => e
      Rails.logger.error("Visitor External Sync Error: #{e.message}")
      { success: false, error: e.message }
    end
  end

  def headers
    {
      'Content-Type' => 'application/json',
      'Authorization' => "Bearer #{@visitor.lotus_token}"
    }
  end

  def parse_response(response)
    begin
      data = JSON.parse(response.body)
      Rails.logger.info("Visitor External Sync Response for Visitor #{@visitor.id}: #{data.to_json}")
      
      if data['isSuccess'] == 'true' || data['isSuccess'] == true
        { success: true, message: 'Visitor synced successfully', response: data }
      else
        Rails.logger.error("Visitor External Sync Failed for Visitor #{@visitor.id}: #{data.to_json}")
        { success: false, error: data['message'] || 'API returned failure', response: data }
      end
    rescue JSON::ParserError
      Rails.logger.error("Visitor External Sync JSON Parse Error for Visitor #{@visitor.id}: #{response.body}")
      { success: false, error: 'Invalid JSON response', response: response.body }
    end
  end
end
