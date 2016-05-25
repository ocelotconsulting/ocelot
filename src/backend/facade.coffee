consul = require './consul'
redis = require './redis'
env = require './env'
couch = require './couch'
config = require 'config'
log = require '../log'

backends = [redis, consul, couch, env]
datastore = null

module.exports =
    init: ->
        datastore = backends.find (backend) -> backend.detect()
        if not datastore
          throw 'no datastore backend found in configuration'

        datastore.init()

    getCachedRoutes: -> datastore.getCachedRoutes()
    getRoutes: -> Promise.resolve().then -> datastore.getRoutes()
    putRoute: (key, route) -> Promise.resolve().then -> datastore.putRoute(key, route)
    deleteRoute: (key) -> Promise.resolve().then -> datastore.deleteRoute(key)

    getCachedHosts: -> datastore.getCachedHosts()
    getHosts: -> Promise.resolve().then -> datastore.getHosts()
    putHost: (group, id, host) -> Promise.resolve().then -> datastore.putHost(group, id, host)
    deleteHost: (group, id) -> Promise.resolve().then -> datastore.deleteHost(group, id)
