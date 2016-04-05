redirect = require '../redirect'
headers = require '../headers'
refresh = require './refresh'

module.exports =
  accept: refresh.accept

  complete: (req, res, route, cookies) ->
      browserRefresh = (result) ->
        headers.setAuthCookies res, route, result
        .then () ->
            redirect.refreshPage req, res

      beginAuthCodeFlow = (err) ->
        redirect.startAuthCode req, res, route

      refresh.token(req, route, cookies)
      .then browserRefresh
      .catch beginAuthCodeFlow
