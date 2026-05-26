require 'net/http'

module Api
  module V1
    module Auth
      class MicrosoftController < ApplicationController
        skip_before_action :verify_authenticity_token
        protect_from_forgery with: :null_session

        # GET /api/v1/auth/microsoft/init
        # Returns the Microsoft OAuth URL for the frontend to redirect to
        def init
          params_str = URI.encode_www_form(
            client_id:     MICROSOFT_OAUTH_CONFIG[:client_id],
            response_type: 'code',
            redirect_uri:  MICROSOFT_OAUTH_CONFIG[:redirect_uri],
            scope:         MICROSOFT_OAUTH_CONFIG[:scopes],
            response_mode: 'query',
            state:         SecureRandom.hex(16)
          )
          render json: { redirect_url: "#{MICROSOFT_AUTH_URL}?#{params_str}" }
        end

        # GET /api/v1/auth/microsoft/callback
        # Microsoft redirects here after login with ?code=...
        def callback
          code = params[:code]

          if code.blank?
            error = params[:error_description] || 'Microsoft login cancelled'
            react_redirect_error(error)
            return
          end

          # Exchange code for tokens
          token_data = exchange_code_for_tokens(code)

          if token_data[:error]
            react_redirect_error(token_data[:error])
            return
          end

          # Get user profile from Microsoft Graph
          profile = fetch_microsoft_profile(token_data[:access_token])

          if profile[:error]
            react_redirect_error(profile[:error])
            return
          end

          # Find user by email — reject if not pre-authorized
          user = User.from_microsoft(
            profile[:email],
            profile[:id],
            token_data[:access_token],
            token_data[:refresh_token],
            token_data[:expires_at]
          )

          if user.nil?
            react_redirect_error("Your email (#{profile[:email]}) is not authorized. Contact your administrator.")
            return
          end

          # Ensure api_key exists
          user.update(api_key: SecureRandom.hex(24)) unless user.api_key.present?

          # Redirect directly to React with api_key — no temp token needed
          # react_url = ENV.fetch('REACT_APP_URL', 'https://app.vibecopilot.ai')
          # react_url = ENV.fetch('REACT_APP_URL', 'https://dummy2.vibecopilot.ai')
          react_url = ENV.fetch('REACT_APP_URL', 'https://horizonemployeeportal.vibecopilot.ai')
          redirect_to "#{react_url}/sso/callback?api_key=#{user.api_key}&user_id=#{user.id}&email=#{CGI.escape(user.email)}&firstname=#{CGI.escape(user.firstname.to_s)}&lastname=#{CGI.escape(user.lastname.to_s)}"
        end

        # POST /api/v1/auth/microsoft/exchange
        # Same as SAML exchange — React sends temp_token, gets api_key back
        def exchange
          temp = SamlTempToken.valid_tokens.find_by(token: params[:temp_token])

          if temp.nil?
            render json: { error: 'Invalid or expired token' }, status: :unauthorized
            return
          end

          user = temp.user
          temp.destroy

          render json: {
            api_key: user.api_key,
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

        private

        def exchange_code_for_tokens(code)
          uri = URI(MICROSOFT_TOKEN_URL)
          res = Net::HTTP.post_form(uri, {
            'client_id'     => MICROSOFT_OAUTH_CONFIG[:client_id],
            'client_secret' => MICROSOFT_OAUTH_CONFIG[:client_secret],
            'code'          => code,
            'redirect_uri'  => MICROSOFT_OAUTH_CONFIG[:redirect_uri],
            'grant_type'    => 'authorization_code'
          })
          data = JSON.parse(res.body)

          if data['access_token']
            {
              access_token:  data['access_token'],
              refresh_token: data['refresh_token'],
              expires_at:    Time.current + data['expires_in'].to_i.seconds
            }
          else
            { error: data['error_description'] || 'Failed to get access token' }
          end
        rescue StandardError => e
          { error: e.message }
        end

        def fetch_microsoft_profile(access_token)
          uri = URI("#{MICROSOFT_GRAPH_URL}/me?$select=id,displayName,givenName,surname,mail,userPrincipalName")
          req = Net::HTTP::Get.new(uri)
          req['Authorization'] = "Bearer #{access_token}"

          res  = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }
          data = JSON.parse(res.body)

          if data['error']
            return { error: data['error']['message'] }
          end

          email = data['mail'] || data['userPrincipalName']
          {
            id:         data['id'],
            email:      email.to_s.downcase.strip,
            firstname:  data['givenName']  || data['displayName'],
            lastname:   data['surname']    || ''
          }
        rescue StandardError => e
          { error: e.message }
        end

        def react_redirect_error(message)
          # react_url = ENV.fetch('REACT_APP_URL', 'https://app.vibecopilot.ai')
          react_url = ENV.fetch('REACT_APP_URL', 'https://horizonemployeeportal.vibecopilot.ai')
          redirect_to "#{react_url}/sso/error?message=#{CGI.escape(message.to_s)}"
        end
      end
    end
  end
end
