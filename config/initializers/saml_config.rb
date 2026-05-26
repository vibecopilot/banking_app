begin
  require 'onelogin/ruby-saml'
  require 'onelogin/ruby-saml/idp_metadata_parser'

  # Load IdP settings from JumpCloud metadata XML
  idp_metadata_parser = OneLogin::RubySaml::IdpMetadataParser.new
  idp_settings = idp_metadata_parser.parse_to_hash(
    File.read(Rails.root.join('config', 'saml', 'idp_metadata.xml'))
  )

  app_url      = ENV.fetch('APP_URL', 'https://admin.vibecopilot.ai')
  react_url    = ENV.fetch('REACT_APP_URL', 'https://app.vibecopilot.ai')

  SAML_SETTINGS_OBJ = OneLogin::RubySaml::Settings.new.tap do |s|
    # IdP settings (loaded from JumpCloud metadata)
    s.idp_entity_id       = idp_settings[:idp_entity_id]
    s.idp_sso_service_url = idp_settings[:idp_sso_service_url]
    s.idp_cert            = idp_settings[:idp_cert]

    # SP settings — your Rails backend
    s.sp_entity_id                   = "#{app_url}/api/v1/auth/saml/metadata"
    s.assertion_consumer_service_url = "#{app_url}/api/v1/auth/saml/callback"

    # SP certificate & private key
    sp_cert_path = Rails.root.join('config', 'saml', 'sp.crt')
    s.certificate = File.read(sp_cert_path) if File.exist?(sp_cert_path)
    s.private_key = ENV['SP_PRIVATE_KEY'].to_s.gsub('\\n', "\n") if ENV['SP_PRIVATE_KEY'].present?

    # NameID format
    s.name_identifier_format = 'urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress'

    # JumpCloud does not require signed AuthnRequests
    s.security[:authn_requests_signed]  = false
    s.security[:want_assertions_signed] = true
    s.security[:digest_method]          = XMLSecurity::Document::SHA256
    s.security[:signature_method]       = XMLSecurity::Document::RSA_SHA256
  end

rescue LoadError
  # ruby-saml gem not installed yet — run: bundle install
  Rails.logger.warn('[SAML] ruby-saml gem not loaded. Run: bundle install')
  SAML_SETTINGS_OBJ = nil
rescue => e
  Rails.logger.error("[SAML] Failed to initialize SAML settings: #{e.message}")
  SAML_SETTINGS_OBJ = nil
end
