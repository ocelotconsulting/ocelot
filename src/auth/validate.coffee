Promise = require 'promise'

oauth = require './oauth'

exports.authentication = (req, route, cookies) ->
  if route and not route['require-auth']
    Promise.resolve()
  else
    oauth.getToken(req, route, cookies).then (oauthToken) ->
      oauth.validate(oauthToken).then (validationResult)
