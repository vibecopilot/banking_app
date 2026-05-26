# require 'googleauth'
# require 'json'
# require 'net/http'
# require 'uri'

# # Path to your Firebase service account credentials JSON
# SERVICE_ACCOUNT_JSON = Rails.root.join('config', 'firebase_credentials.json')

# # Scopes needed to access FCM
# SCOPES = ['https://www.googleapis.com/auth/firebase.messaging']

# # Authenticate and get an OAuth2 token
# def authenticate_with_google
#   credentials = Google::Auth::ServiceAccountCredentials.make_creds(
#     json_key_io: File.open(SERVICE_ACCOUNT_JSON),
#     scope: SCOPES
#   )

#   # Fetch and return the access token
#   credentials.fetch_access_token!['access_token']
# end
