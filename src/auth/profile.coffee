config = require 'config'
agent = require('../http-agent')
cache = require 'memory-cache'
log = require '../log'

expectedResultTimeout = 7200000
unexpectedResultTimeout = 5000
url = config.get 'authentication.profile-endpoint' if config.has 'authentication.profile-endpoint'

module.exports =
  getProfile: (authentication, route, token) ->
    Promise.resolve().then ->
      userId = authentication.access_token?.user_id
      appId = route['ent-app-id'] or ''
      if url and userId and appId
        actualUrl = url.replace('$userId', encodeURIComponent(userId)).replace('$appId', encodeURIComponent(appId))
        tokenKey = 'profile_' + token
        cache.get(tokenKey) or agent.getAgent().get(actualUrl).set('Authorization', 'Bearer ' + token).then (res) ->
          profile = res.body
          timeout = if profile then expectedResultTimeout else unexpectedResultTimeout
          cache.put tokenKey, profile or {}, timeout
          profile
        , ->
          cache.put tokenKey, {}, unexpectedResultTimeout
