require 'onelogin/ruby-saml'

# Builds a SAML AuthnRequest for SP-initiated SSO to a specific portal
# Used when an employee clicks a portal tile to auto-login
class SamlSsoService
  attr_reader :error

  def initialize(portal, user)
    @portal = portal
    @user   = user
  end

  def build_redirect_url
    unless @portal.saml_idp_sso_url.present?
      @error = "Portal #{@portal.name} has no SSO URL configured"
      return nil
    end

    settings = portal_saml_settings
    request  = OneLogin::RubySaml::Authrequest.new

    # Pass user email as login hint so the portal pre-fills the email
    params = {}
    params['login_hint'] = @user.email if @user.email.present?

    request.create(settings, params)
  rescue StandardError => e
    @error = e.message
    Rails.logger.error("[SAML SSO] Error building redirect for portal #{@portal.slug}: #{e.message}")
    nil
  end

  private

  def portal_saml_settings
    OneLogin::RubySaml::Settings.new.tap do |s|
      s.idp_sso_service_url = @portal.saml_idp_sso_url
      s.idp_entity_id       = @portal.saml_idp_entity_id
      s.idp_cert            = @portal.saml_idp_cert

      s.sp_entity_id        = ENV.fetch('APP_URL', 'https://admin.vibecopilot.ai')
      s.name_identifier_format = 'urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress'

      sp_cert_path = Rails.root.join('config', 'saml', 'sp.crt')
      s.certificate = File.read(sp_cert_path) if File.exist?(sp_cert_path)
      s.private_key = ENV['SP_PRIVATE_KEY'].to_s.gsub('\\n', "\n") if ENV['SP_PRIVATE_KEY'].present?

      s.security[:authn_requests_signed] = false
    end
  end
end
