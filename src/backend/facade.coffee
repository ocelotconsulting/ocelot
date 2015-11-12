consul = require './consul'
redis = require './redis'
config = require 'config'
datastore = undefined
jwks = require './jwks'

module.exports =
    init: ->
        if consul.detect()
            datastore = consul
        else if redis.detect()
            datastore = redis
        else
            throw 'no datastore backend found in configuration'

        if not config.has 'jwks.url' then throw 'no jwks url found in configuration'
        jwks.init()

        datastore.init()
    getRoutes: ->
        datastore.getRoutes()
    getHosts: ->
        datastore.getHosts()
    putRoute: (id, route) ->
        datastore.putRoute(id, route)
    deleteRoute: (id) ->
        datastore.deleteRoute(id)
    putHost: (id, route) ->
        datastore.putHost(id, route)
    deleteHost: (id) ->
        datastore.deleteHost(id)
    getJWKS: ->
        jwks.getKeys
    reloadData: ->
        datastore.reloadData()
        jwks.reloadData()