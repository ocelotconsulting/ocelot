headers = require '../headers'
refresh = require './refresh'
response = require '../../response'
tokenInfo = require '../token-info'

module.exports =
  accept: (req, route, cookies) ->
    req.url.split('?')[0].endsWith('auth-token-refresh') and refresh.accept(route, cookies)

  complete: (req, res, route, cookies) ->
    thingsAreOk = (auth) ->
      auth.token = auth.access_token
      auth.obtained_on = new Date().getTime()
      headers.setAuthCookies res, route, auth
      .then () ->
        tokenInfo.complete route, res, auth

    thingsAreNotOk = (err) ->
      log.error "Refresh error for route #{route.route} when using cookie #{cookieName}: #{err}; for query #{formData}"
      response(res, 500, err)

    refresh.token(req, route, cookies).then thingsAreOk, thingsAreNotOk
