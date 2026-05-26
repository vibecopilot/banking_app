class ExternalUserSyncService
  BASE_URL = 'http://103.76.77.112:8090/api/user/createOrUpdate'

  def initialize(user, company_id = 56)
    @user = user
    @company_id = company_id
  end

  def sync
    return { success: false, error: 'User not found' } unless @user.present?
    return { success: false, error: 'lotus_token is missing for this user' } unless @user.lotus_token.present?

    payload = build_payload
    Rails.logger.info("User Sync Payload for User #{@user.id}: #{payload.to_json}")
    send_request(payload)
  end

  private

  def build_payload
    {
      company_code: '01',
      location_code: 'MUM',
      usertype: 'EmpMaster',
      code: @user.id.to_s,
      name: @user.full_name,
      emailId: @user.email,
      mobile: @user.mobile,
      phone1: '',
      address1: @user.user_address || '',
      address2: '',
      city: '',
      pincode: '',
      state: '',
      dob: @user.birth_date&.strftime('%d/%m/%Y') || '',
      district: '',
      country: 'India',
      doj: @user.date_of_joining&.strftime('%d/%m/%Y') || Date.today.strftime('%d/%m/%Y')
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
      Rails.logger.error("External User Sync Error: #{e.message}")
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
      Rails.logger.info("External User Sync Response for User #{@user.id}: #{data.to_json}")
      
      if data['isSuccess'] == 'true' || data['isSuccess'] == true
        { success: true, message: 'User synced successfully', response: data }
      else
        Rails.logger.error("External User Sync Failed for User #{@user.id}: #{data.to_json}")
        { success: false, error: data['message'] || 'API returned failure', response: data }
      end
    rescue JSON::ParserError
      Rails.logger.error("External User Sync JSON Parse Error for User #{@user.id}: #{response.body}")
      { success: false, error: 'Invalid JSON response', response: response.body }
    end
  end
end
