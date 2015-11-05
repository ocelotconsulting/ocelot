consul = require './consul'
redis = require './redis'
config = require 'config'
datastore = undefined
jwks = require './jwks'

module.exports =
    init: ->
        if not config.has 'jwks.url' then throw 'no jwks url found in configuration'
        datastore = if config.has 'backend.consul' then consul
        else if config.has 'backend.redis' then redis
        else throw 'no backend found in configuration'
        jwks.init()
        datastore.init()
    getRoutes: ->
        datastore.getRoutes()
    getServices: ->
        datastore.getServices()
    getRoute: (id) ->
        datastore.getRoute(id)
    putRoute: (id, route) ->
        datastore.putRoute(id, route)
    deleteRoute: (id) ->
        datastore.deleteRoute(id)
    getHost: (id) ->
        datastore.getHost(id)
    putHost: (id, route) ->
        datastore.putHost(id, route)
    deleteHost: (id) ->
        datastore.deleteHost(id)
    getJWKS: ->
        jwks.getKeys
    reloadData: ->
        datastore.reloadData()
        jwks.reloadData()