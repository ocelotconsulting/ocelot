config = require 'config'
agent = require('../http-agent')
url = config.get 'authentication.user-info'
cache = require 'memory-cache'
log = require '../log'

module.exports =
    getUserInfo: (token, route) ->
      Promise.resolve().then =>
        if route.scope?.split(' ').indexOf('openid') > -1
          tokenKey = 'user-info_' + token
          cache.get(tokenKey) or agent.getAgent().get(url).set('Authorization', 'Bearer ' + token).then (res) ->
            if res.body
              cache.put tokenKey, res.body, 7200000
              res.body
            else
              log.error 'invalid json response from user info endpoint', err.response.statusCode, err.response.body
              cache.put tokenKey, {}, 30000
          , (err) ->
            if err.response.statusCode >= 400 and err.response.statusCode < 500
              # assume there is no user info for this token, the route scope may have changed..
              cache.put tokenKey, {}, 7200000
            else
              log.error 'unexpected error from user info endpoint', err.response.statusCode, err.response.body
              cache.put tokenKey, {}, 30000
