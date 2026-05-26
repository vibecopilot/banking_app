class TagAssignmentService
  BASE_URL = 'http://103.76.77.112:8090/api/tagassignment/assign'

  def initialize(user, company_id = 56)
    @user = user
    @company_id = company_id
  end

  def assign_tag
    return { success: false, error: 'User not found' } unless @user.present?
    return { success: false, error: 'lotus_token is missing for this user' } unless @user.lotus_token.present?
    return { success: false, error: 'start_date is missing for this user' } unless @user.start_date.present?
    return { success: false, error: 'end_date is missing for this user' } unless @user.end_date.present?
    
    card = @user.cards.first
    return { success: false, error: 'No card assigned to this user' } unless card.present?
    return { success: false, error: 'Card ID is missing' } unless card.card_id.present?

    payload = build_payload(card)
    Rails.logger.info("Tag Assignment Payload for User #{@user.id}: #{payload.to_json}")
    send_request(payload)
  end

  private

  def build_payload(card)
    {
      company_code: '01',
      location_code: 'MUM',
      empCode: @user.id.to_s,
      tagType: card.tag_type || 'BLE',
      fromDate: @user.start_date.strftime('%d/%m/%Y'),
      toDate: @user.end_date.strftime('%d/%m/%Y'),
      tagNumber: card.card_id
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
      Rails.logger.error("Tag Assignment Error: #{e.message}")
      { success: false, error: e.message }
    end
  end

  def headers
    {
      'Content-Type' => 'application/json',
      'Authorization' => "Bearer #{@user.lotus_token}"
    }
  end

  def parse_response(response)
    begin
      data = JSON.parse(response.body)
      Rails.logger.info("Tag Assignment Response for User #{@user.id}: #{data.to_json}")
      
      if data['isSuccess'] == 'true' || data['isSuccess'] == true
        { success: true, message: 'Tag assigned successfully', response: data }
      else
        Rails.logger.error("Tag Assignment Failed for User #{@user.id}: #{data.to_json}")
        { success: false, error: data['message'] || 'API returned failure', response: data }
      end
    rescue JSON::ParserError
      Rails.logger.error("Tag Assignment JSON Parse Error for User #{@user.id}: #{response.body}")
      { success: false, error: 'Invalid JSON response', response: response.body }
    end
  end
end
