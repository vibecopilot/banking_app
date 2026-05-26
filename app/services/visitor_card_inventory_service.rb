class VisitorCardInventoryService
  BASE_URL = 'http://103.76.77.112:8090/api/cardInventory/get'

  def initialize(visitor, company_id = 56)
    @visitor = visitor
    @company_id = company_id
  end

  def fetch_and_save_cards
    return { success: false, error: 'Visitor not found' } unless @visitor.present?
    return { success: false, error: 'lotus_token is missing for this visitor' } unless @visitor.lotus_token.present?

    cards_data = fetch_cards
    return cards_data unless cards_data[:success]

    save_cards(cards_data[:data])
  end

  private

  def fetch_cards
    payload = {
      company_code: '01',
      tagType: 'QR',
      status: 'unassigned'
    }

    uri = URI(BASE_URL)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.path, headers)
    request.body = payload.to_json

    begin
      response = http.request(request)
      parse_response(response)
    rescue StandardError => e
      Rails.logger.error("Visitor Card Inventory Fetch Error: #{e.message}")
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
      response_data = JSON.parse(response.body)
      
      # Extract the data field which contains the JSON string
      if response_data['data'].is_a?(String)
        begin
          cards_array = JSON.parse(response_data['data'])
          { success: true, data: cards_array, message: 'Cards fetched successfully' }
        rescue JSON::ParserError
          { success: false, error: 'Invalid JSON in data field', response: response.body }
        end
      else
        { success: true, data: response_data['data'], message: 'Cards fetched successfully' }
      end
    rescue JSON::ParserError
      { success: false, error: 'Invalid JSON response', response: response.body }
    end
  end

  def save_cards(cards_data)
    saved_count = 0
    failed_count = 0
    errors = []

    # Handle if cards_data is a JSON string
    if cards_data.is_a?(String)
      begin
        cards_data = JSON.parse(cards_data)
      rescue JSON::ParserError
        return {
          success: false,
          error: 'Invalid JSON in card data',
          saved_count: 0,
          failed_count: 1
        }
      end
    end

    # Handle if cards_data is an array or a single object
    cards_array = cards_data.is_a?(Array) ? cards_data : [cards_data]

    # Save only the first card
    if cards_array.present?
      card_info = cards_array.first
      
      begin
        card = VisitorCard.find_or_initialize_by(
          card_id: card_info['Card ID'],
          visitor_id: @visitor.id
        )

        card.company_code = '01'
        card.tag_type = card_info['ID Type'] || 'QR'
        card.status = card_info['Status'] || 'Unassigned'
        card.card_data = card_info

        if card.save
          saved_count += 1
          Rails.logger.info("Visitor Card saved: #{card.id} - Card ID: #{card_info['Card ID']}")
        else
          failed_count += 1
          errors << { card_info: card_info, error: card.errors.full_messages.join(', ') }
          Rails.logger.error("Failed to save visitor card: #{card.errors.full_messages.join(', ')}")
        end
      rescue StandardError => e
        failed_count += 1
        errors << { card_info: card_info, error: e.message }
        Rails.logger.error("Error saving visitor card: #{e.message}")
      end
    end

    {
      success: true,
      saved_count: saved_count,
      failed_count: failed_count,
      errors: errors,
      message: "Saved #{saved_count} card(s)"
    }
  end
end
