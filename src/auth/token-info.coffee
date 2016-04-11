response = require '../response'

module.exports =
  accept: (req) ->
    req.url.split('?')[0].endsWith('auth-token-info')
  complete: (route, res, auth) ->
    tokenAgeInSeconds = (new Date().getTime() - (auth.obtained_on)) / 1000
    ttlSeconds = auth.expires_in - Math.round(tokenAgeInSeconds)
    ttlSeconds = 0 if ttlSeconds < 0

    response.sendJSON(res, 200,
      'cookie-name': route['cookie-name'] or ''
      'cookies-enabled': route['cookie-name'] and route['require-auth']
      'expires_in' : ttlSeconds
      'access_token': auth.token
      'user-profile': auth['profile']
      'user-id': auth.access_token?.user_id?.toLowerCase(),
      'client-id': auth?.client_id
    )
