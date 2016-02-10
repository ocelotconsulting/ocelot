Promise = require 'promise'

oauth = require './oauth'
oidc = require './oidc'

oidc.init()

exports.authentication = (req, route, cookies) ->
  if route and not route['require-auth']
    Promise.resolve()
  else
    oauth.getToken(req, route, cookies).then (oauthToken) ->
      oauth.validate(oauthToken).then (validationResult) ->
        oidc.getToken(req, route, cookies).then (oidcToken) ->
          oidc.validate(oidcToken).then (claims) ->
            validationResult.claims = claims
            validationResult
        , -> validationResult
