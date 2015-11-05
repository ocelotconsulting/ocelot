consul = require './consul'
redis = require './redis'
config = require 'config'
backend = undefined
jwks = require './jwks'

module.exports =
    init: ->
        if not config.has 'jwks.url' then throw 'no jwks url found in configuration'
        backend = if config.has 'backend.consul' then consul
        else if config.has 'backend.redis' then redis
        else throw 'no backend found in configuration'
        jwks.init()
        backend.init()
    getRoutes: ->
        backend.getRoutes()
    getServices: ->
        backend.getServices()
    getJWKS: ->
        jwks.getKeys
    reloadData: ->
        backend.reloadData()
        jwks.reloadData()