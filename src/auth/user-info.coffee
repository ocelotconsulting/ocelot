config = require 'config'
agent = require('../http-agent')
cache = require 'memory-cache'
log = require '../log'

expectedResultTimeout = 7200000
unexpectedResultTimeout = 5000
url = config.get 'authentication.user-info' if config.has 'authentication.user-info'

module.exports =
    getUserInfo: (token, route) ->
      Promise.resolve().then ->
        if url and route.scope?.split(' ').indexOf('openid') > -1
          tokenKey = 'user-info_' + token
          cache.get(tokenKey) or agent.getAgent().get(url).set('Authorization', 'Bearer ' + token).then (res) ->
            timeout = if res.body then expectedResultTimeout else unexpectedResultTimeout
            cache.put tokenKey, res.body or {}, timeout
            res.body
          , (err) ->
            timeout = if err.response.statusCode == 403 then expectedResultTimeout else unexpectedResultTimeout
            cache.put tokenKey, {}, timeout
