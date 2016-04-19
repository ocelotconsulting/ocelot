httpAgent = require './http-agent'
config = require 'config'
cache = require 'memory-cache'

module.exports =
  getToken: () ->
    Promise.resolve().then () ->
      token = cache.get 'token'
      if token
        token
      else
        httpAgent.getAgent()
        .post config.get('authentication.token-endpoint')
        .type 'form'
        .send
          grant_type: 'client_credentials'
          client_id: config.get('authentication.validation-client')
          client_secret: config.get('authentication.validation-secret')
        .then (res) ->
          tokenResponse = res.body
          cache.put 'token', tokenResponse['access_token'], ((tokenResponse['expires_in'] - 30) * 1000)
          tokenResponse['access_token']
