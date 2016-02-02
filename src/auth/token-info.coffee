response = require '../response'

module.exports =
  accept: (req) -> req.url.indexOf('auth-token-info') > -1
  complete: (route, res) ->
    cookieName = if route['cookie-name'] then route['cookie-name'] else ''
    cookiesEnabled = cookieName?
    response.sendJSON(res, 200,
      'cookie-name': cookieName
      'cookies-enabled': cookiesEnabled)
