response = require '../response'

endsWith = (str, suffix) ->
  str.indexOf(suffix, str.length - suffix.length) != -1

module.exports =
  accept: (req) ->
    endsWith(req.url.split('?')[0], 'auth-token-info')
  complete: (route, res) ->
    response.sendJSON(res, 200,
      'cookie-name': route['cookie-name'] or ''
      'cookies-enabled': route['cookie-name'] and route['require-auth'])
