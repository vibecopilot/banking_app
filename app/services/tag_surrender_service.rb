class TagSurrenderService
  BASE_URL = 'http://103.76.77.112:8090/api/tagassignment/surrender'

  def initialize(visitor, company_id = 56)
    @visitor = visitor
    @company_id = company_id
  end

  def surrender_tag
    return { success: false, error: 'Visitor not found' } unless @visitor.present?
    return { success: false, error: 'lotus_token is missing' } unless @visitor.lotus_token.present?

    card = @visitor.visitor_cards.first
    return { success: false, error: 'No card assigned to this visitor' } unless card.present?
    return { success: false, error: 'Card ID is missing' } unless card.card_id.present?

    payload = build_payload(card)
    Rails.logger.info("Tag Surrender Payload for Visitor #{@visitor.id}: #{payload.to_json}")
    send_request(payload)
  end

  private

  def build_payload(card)
    {
      company_code: '01',
      location_code: 'MUM',
      empCode: @visitor.id.to_s,
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
      Rails.logger.error("Tag Surrender Error for Visitor #{@visitor.id}: #{e.message}")
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
      Rails.logger.info("Tag Surrender Response for Visitor #{@visitor.id}: #{data.to_json}")

      if data['isSuccess'] == 'true' || data['isSuccess'] == true
        { success: true, message: 'Tag surrendered successfully', response: data }
      else
        Rails.logger.error("Tag Surrender Failed for Visitor #{@visitor.id}: #{data.to_json}")
        { success: false, error: data['message'] || 'API returned failure', response: data }
      end
    rescue JSON::ParserError
      Rails.logger.error("Tag Surrender JSON Parse Error for Visitor #{@visitor.id}: #{response.body}")
      { success: false, error: 'Invalid JSON response', response: response.body }
    end
  end
end
