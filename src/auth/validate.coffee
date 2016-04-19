Promise = require 'promise'
oauth = require './oauth'

exports.authentication = (req, route, cookies) ->
  Promise.resolve().then () ->
    if route['require-auth']
      oauth.getToken(req, route, cookies)
      .then (oauthToken) ->
        oauth.validate(oauthToken)
