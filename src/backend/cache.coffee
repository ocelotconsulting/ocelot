consul = require './consul'
config = require 'config'
backend = undefined
jwks = require './jwks'

module.exports =
    initCache: ->
        if not config.has 'jwks.url' then throw 'no jwks url found in configuration'
        backend = if config.has 'backend.consul' then consul else throw 'no backend found in configuration'
        jwks.initCache()
        backend.initCache()
    getRoutes: ->
        backend.getRoutes()
    getServices: ->
        backend.getServices()
    getJWKS: ->
        jwks.getKeys
    reloadData: ->
        backend.reloadData()
        jwks.reloadData()