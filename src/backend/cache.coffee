consul = require './consul'
config = require 'config'
backend = undefined
jwks = require './jwks'

module.exports =
    initCache: ->
        if config.has('backend.consul')
            backend = consul
        else
            throw 'no backend found in configuration'
        if !config.has('jwks.url')
            throw 'no jwks url found in configuration'
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