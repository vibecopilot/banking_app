MICROSOFT_OAUTH_CONFIG = {
  client_id:     ENV.fetch('MICROSOFT_CLIENT_ID'),
  client_secret: ENV.fetch('MICROSOFT_CLIENT_SECRET'),
  tenant:        ENV.fetch('MICROSOFT_TENANT',        'common'),
  redirect_uri:  ENV.fetch('MICROSOFT_REDIRECT_URI',  'https://horizonemployeeportal.vibecopilot.ai/api/v1/auth/microsoft/callback'),
  scopes:        'openid email profile offline_access User.Read'
}.freeze

MICROSOFT_AUTH_URL   = "https://login.microsoftonline.com/#{MICROSOFT_OAUTH_CONFIG[:tenant]}/oauth2/v2.0/authorize"
MICROSOFT_TOKEN_URL  = "https://login.microsoftonline.com/#{MICROSOFT_OAUTH_CONFIG[:tenant]}/oauth2/v2.0/token"
MICROSOFT_GRAPH_URL  = 'https://graph.microsoft.com/v1.0'
