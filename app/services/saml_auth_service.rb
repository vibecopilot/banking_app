require 'onelogin/ruby-saml'

# Validates the incoming SAML response from JumpCloud
# and returns the authenticated user or an error
class SamlAuthService
  attr_reader :error

  def initialize(saml_response_param, request_url)
    @saml_response_param = saml_response_param
    @request_url         = request_url
  end

  def call
    response = OneLogin::RubySaml::Response.new(
      @saml_response_param,
      settings:          SAML_SETTINGS_OBJ,
      allowed_clock_drift: 5.seconds
    )

    unless response.is_valid?
      @error = response.errors.join(', ')
      Rails.logger.error("[SAML] Invalid response: #{@error}")
      return nil
    end

    user = User.from_saml(response)
    Rails.logger.info("[SAML] Authenticated user: #{user.email}")
    user
  rescue StandardError => e
    @error = e.message
    Rails.logger.error("[SAML] Exception: #{e.message}")
    nil
  end
end
