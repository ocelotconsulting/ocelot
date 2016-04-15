Promise = require 'promise'
oauth = require './oauth'
userInfo = require './user-info'
profile = require './profile'
log = require '../log'

exports.authentication = (req, route, cookies) ->
  if route and not route['require-auth']
    Promise.resolve()
  else
    oauth.getToken(req, route, cookies).then (oauthToken) ->
      oauth.validate(oauthToken).then (authentication) ->
        #todo: move this crap out
        profile.getProfile(authentication, route, oauthToken)
        .then (profile) ->
          if profile
            authentication.profile = profile
          authentication
        , () ->
          authentication
