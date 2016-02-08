consul = require './consul'
redis = require './redis'
config = require 'config'
datastore = undefined
log = require '../log'

module.exports =
    init: ->
        if consul.detect()
            log.debug 'Consul backend detected'
            datastore = consul
        else if redis.detect()
            log.debug 'Redis backend detected'
            datastore = redis
        else
            throw 'no datastore backend found in configuration'

        datastore.init()

    getCachedRoutes: -> datastore.getCachedRoutes()
    getRoutes: -> datastore.getRoutes()
    putRoute: (key, route) -> datastore.putRoute(key, route)
    deleteRoute: (key) -> datastore.deleteRoute(key)

    getCachedHosts: -> datastore.getCachedHosts()
    getHosts: -> datastore.getHosts()
    putHost: (group, id, host) -> datastore.putHost(group, id, host)
    deleteHost: (group, id) -> datastore.deleteHost(group, id)