consul = require './consul'
redis = require './redis'
config = require 'config'
datastore = undefined
jwks = require './jwks'

# todo: get rid of this module
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
    putRoute: (key, route) ->
        datastore.putRoute(key, route)
    deleteRoute: (key) ->
        datastore.deleteRoute(key)
    putHost: (key, host) ->
        datastore.putHost(key, host)
    deleteHost: (key) ->
        datastore.deleteHost(key)
    getJWKS: ->
        jwks.getKeys
    reloadData: ->
        datastore.reloadData()
        jwks.reloadData()