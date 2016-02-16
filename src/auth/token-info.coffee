response = require '../response'

endsWith = (str, suffix) ->
  str.indexOf(suffix, str.length - suffix.length) != -1

module.exports =
  accept: (req) -> endsWith(req.url.split('?')[0], 'auth-token-info')
  complete: (route, res) ->
    cookieName = if route['cookie-name'] then route['cookie-name'] else ''
    cookiesEnabled = cookieName?
    response.sendJSON(res, 200,
      'cookie-name': cookieName
      'cookies-enabled': cookiesEnabled)
