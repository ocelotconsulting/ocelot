module.exports =

  authentication:
    'validation-client': "MY_FAKE_CLIENT_ID"
    'validation-secret': "MY_FAKE_SECRET_ID"
    'validation-grant-type': "MY_VALIDATION_GRANT_TYPE"
    'user-path': 'access_token.user_id'
    'client-path': 'client_id'
    'token-endpoint': "https://testy.local/as/token.oauth2"
    'auth-endpoint': "https://testy.local/as/authorization.oauth2"
    'profile-endpoint': 'https://profile.local/v1/users/$userId?fields=id,firstName,middleName,lastName,entitlements,email,fullName&apps=$appId'

  'cors-domains': ["localhost"]
  'api-clients': ["OCELOT-UI"]
  'default-protocol': "http"
  'enforce-https': false
  'cors-domains': ["localhost", "testy.com"]

  backend:
    provider: "couch"
    url: "http://user:pass@127.0.0.1:5984"

  log:
    level: "debug"
