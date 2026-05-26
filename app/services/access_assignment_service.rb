class AccessAssignmentService
  BASE_URL = 'http://103.76.77.112:8090/api/assignaccess/create'

  def initialize(entity, entity_type = 'user', company_id = 56)
    @entity = entity
    @entity_type = entity_type # 'user' or 'visitor'
    @company_id = company_id
  end

  def assign_access
    return { success: false, error: 'Entity not found' } unless @entity.present?
    return { success: false, error: 'lotus_token is missing' } unless @entity.lotus_token.present?

    payload = build_payload
    Rails.logger.info("Access Assignment Payload for #{@entity_type.capitalize} #{@entity.id}: #{payload.to_json}")
    send_request(payload)
  end

  private

  def build_payload
    {
      empCode: @entity.id.to_s,
      company_code: '01',
      location_code: 'MUM',
      accessGroupCodes: access_group_codes
    }
  end

  def access_group_codes
    case @entity_type
    when 'user'
      ["001"]
    when 'visitor'
      ["001"]
    else
      []
    end
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
      Rails.logger.error("Access Assignment Error for #{@entity_type} #{@entity.id}: #{e.message}")
      { success: false, error: e.message }
    end
  end

  def headers
    {
      'Content-Type' => 'application/json',
      'Authorization' => "Bearer #{@entity.lotus_token}"
    }
  end

  def parse_response(response)
    begin
      data = JSON.parse(response.body)
      Rails.logger.info("Access Assignment Response for #{@entity_type.capitalize} #{@entity.id}: #{data.to_json}")
      
      if data['isSuccess'] == 'true' || data['isSuccess'] == true
        { success: true, message: 'Access assigned successfully', response: data }
      else
        Rails.logger.error("Access Assignment Failed for #{@entity_type.capitalize} #{@entity.id}: #{data.to_json}")
        { success: false, error: data['message'] || 'API returned failure', response: data }
      end
    rescue JSON::ParserError
      Rails.logger.error("Access Assignment JSON Parse Error for #{@entity_type.capitalize} #{@entity.id}: #{response.body}")
      { success: false, error: 'Invalid JSON response', response: response.body }
    end
  end
end
