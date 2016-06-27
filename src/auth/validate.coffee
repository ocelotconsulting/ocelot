oauth = require './oauth'

exports.authentication = (req, route, cookies) ->
  Promise.resolve().then () ->
    if not route or route['require-auth'] == true
      oauth.getToken(req, route, cookies)
      .then (oauthToken) ->
        oauth.validate(oauthToken)
