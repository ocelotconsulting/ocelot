config = require 'config'
agent = require('../http-agent')
cache = require 'memory-cache'
log = require '../log'
user = require './user'
tokenUtil = require './token-util'

unexpectedResultTimeout = 5000
url = config.get 'authentication.profile-endpoint' if config.has 'authentication.profile-endpoint'

module.exports =
  getProfile: (req, token) ->
    route = req._route
    Promise.resolve().then ->
      userId = user.getUserId(req)
      appId = route['ent-app-id'] or ''
      requestToken = req._auth?.token

      if url and userId and route['user-profile-enabled'] and requestToken
        actualUrl = url.replace('$userId', encodeURIComponent(userId)).replace('$appId', encodeURIComponent(appId))
        tokenKey = "profile_#{requestToken}_#{userId}_#{appId}"
        cache.get(tokenKey) or agent.getAgent().get(actualUrl).set('Authorization', 'Bearer ' + token).then (res) ->
          profile = res.body
          timeout = if profile then (tokenUtil.getExpirationSeconds(req._auth) * 1000) else unexpectedResultTimeout
          cache.put tokenKey, profile or {}, timeout
          profile
        , ->
          cache.put tokenKey, {}, unexpectedResultTimeout
          {}
