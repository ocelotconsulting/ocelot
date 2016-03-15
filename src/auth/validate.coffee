Promise = require 'promise'
oauth = require './oauth'
userInfo = require './user-info'
log = require '../log'

exports.authentication = (req, route, cookies) ->
  if route and not route['require-auth']
    Promise.resolve()
  else
    oauth.getToken(req, route, cookies).then (oauthToken) ->
      validatePromise = oauth.validate(oauthToken)
      userInfoPromise = userInfo.getUserInfo(oauthToken, route)
      validatePromise.then (authentication) ->
        userInfoPromise.then (userInfo) ->
          authentication['user-info'] = userInfo if userInfo?.sub
          authentication
        , (err) ->
          log.error 'unexpected error loading user info', err
          authentication
