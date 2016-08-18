response = require '../response'
context = require './context'

module.exports =
  accept: (req) ->
    req.url.split('?')[0].endsWith('auth-token-info')
  complete: (req, res) ->
    auth = req._auth
    route = req._route
    profile = req._profile

    tokenAgeInSeconds = (new Date().getTime() - (auth.obtained_on)) / 1000
    ttlSeconds = auth.expires_in - Math.round(tokenAgeInSeconds)
    ttlSeconds = 0 if ttlSeconds < 0

    response.sendJSON(res, 200,
      'cookie-name': route['cookie-name'] or ''
      'cookies-enabled': route['cookie-name'] and route['require-auth']
      'expires_in' : ttlSeconds
      'access_token': auth.token
      'user-profile': profile
      'user-id': context.getUserId(req),
      'client-id': context.getClientId(req)
    )
