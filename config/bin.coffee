module.exports =
  authentication:
    'validation-client': "TPS_VALIDATOR"
    'validation-secret': "I7PM4yBf"
    'validation-grant-type': "urn:pingidentity.com:oauth2:grant_type:validate_bearer"
    'token-endpoint': "https://test.amp.monsanto.com/as/token.oauth2"
    'auth-endpoint': "https://test.amp.monsanto.com/as/authorization.oauth2"
    'profile-endpoint': 'https://profile.velocity-np.ag/v1/users/$userId?fields=id,firstName,middleName,lastName,entitlements,email,fullName&apps=$appId'

  jwks:
    url: "https://test.amp.monsanto.com/pf/JWKS"

  'cors-domains': ["localhost"]
  'default-protocol': "http"
  'enforce-https': false
  'cors-domains': ["localhost"]
  'log-level': "debug"
