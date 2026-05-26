require 'onelogin/ruby-saml'

module Api
  module V1
    module Auth
      class SamlController < ApplicationController
        # Skip CSRF and HTML-only checks — this is a pure API/SAML endpoint
        skip_before_action :verify_authenticity_token
        protect_from_forgery with: :null_session

        # ─────────────────────────────────────────────────────────────
        # GET /api/v1/auth/saml/init
        # React calls this first. Returns the JumpCloud redirect URL.
        # Frontend does: window.location.href = response.redirect_url
        # ─────────────────────────────────────────────────────────────
        def init
          request_obj = OneLogin::RubySaml::Authrequest.new
          redirect_url = request_obj.create(SAML_SETTINGS_OBJ)
          render json: { redirect_url: redirect_url }
        end

        # ─────────────────────────────────────────────────────────────
        # POST /api/v1/auth/saml/callback
        # JumpCloud POSTs here after the employee authenticates.
        # We validate, find/create the user, create a temp token,
        # then redirect the browser to React with the temp token.
        # ─────────────────────────────────────────────────────────────
        def callback
          service = SamlAuthService.new(params[:SAMLResponse], request.url)
          user    = service.call

          if user.nil?
            react_url = ENV.fetch('REACT_APP_URL', 'https://horizonemployeeportal.vibecopilot.ai')
            redirect_to "#{react_url}/sso/error?message=#{CGI.escape(service.error.to_s)}"
            return
          end

          # Ensure user has an api_key (your existing auth token)
          user.update(api_key: SecureRandom.hex(24)) unless user.api_key.present?

          # Create a short-lived one-time token (2 min expiry)
          temp = SamlTempToken.generate_for(user)

          # Redirect browser back to React with the temp token in URL
          react_url = ENV.fetch('REACT_APP_URL', 'https://horizonemployeeportal.vibecopilot.ai')
          redirect_to "#{react_url}/sso/callback?temp_token=#{temp.token}"        end

        # ─────────────────────────────────────────────────────────────
        # POST /api/v1/auth/saml/exchange
        # React calls this with the temp_token to get the real api_key.
        # Single-use — token is deleted after exchange.
        # ─────────────────────────────────────────────────────────────
        def exchange
          temp = SamlTempToken.valid_tokens.find_by(token: params[:temp_token])

          if temp.nil?
            render json: { error: 'Invalid or expired token' }, status: :unauthorized
            return
          end

          user = temp.user
          temp.destroy # single-use

          render json: {
            api_key:   user.api_key,
            user: {
              id:        user.id,
              email:     user.email,
              firstname: user.firstname,
              lastname:  user.lastname,
              user_type: user.user_type,
              full_name: user.full_name
            }
          }
        end

        # ─────────────────────────────────────────────────────────────
        # GET /api/v1/auth/saml/metadata
        # SP metadata endpoint — register this URL with JumpCloud
        # as your SP Entity ID.
        # ─────────────────────────────────────────────────────────────
        def metadata
          meta = OneLogin::RubySaml::Metadata.new
          render xml: meta.generate(SAML_SETTINGS_OBJ), content_type: 'application/xml'
        end
      end
    end
  end
end
