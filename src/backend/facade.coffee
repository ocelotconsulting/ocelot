consul = require './consul'
redis = require './redis'
env = require './env'
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
        else if env.detect()
            log.debug 'Environment backend detected'
            datastore = env
        else
            throw 'no datastore backend found in configuration'

        datastore.init()

    getCachedRoutes: -> datastore.getCachedRoutes()
    getRoutes: -> Promise.resolve().then -> datastore.getRoutes()
    putRoute: (key, route) -> Promise.resolve().then -> Promise.resolve datastore.putRoute(key, route)
    deleteRoute: (key) -> Promise.resolve().then -> Promise.resolve datastore.deleteRoute(key)

    getCachedHosts: -> datastore.getCachedHosts()
    getHosts: -> Promise.resolve().then -> datastore.getHosts()
    putHost: (group, id, host) -> Promise.resolve().then -> datastore.putHost(group, id, host)
    deleteHost: (group, id) -> Promise.resolve().then -> datastore.deleteHost(group, id)
