redirect = require '../redirect'
setCookies = require '../set-cookies'
refresh = require './refresh'

module.exports =
  accept: refresh.accept

  complete: (req, res, route, cookies) ->
      browserRefresh = (result) ->
        setCookies.setAuthCookies res, route, result
        .then () ->
            redirect.refreshPage req, res

      beginAuthCodeFlow = (err) ->
        redirect.startAuthCode req, res, route

      refresh.token(req, route, cookies)
      .then browserRefresh
      .catch beginAuthCodeFlow
