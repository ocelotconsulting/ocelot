consul = require './consul'
redis = require './redis'
env = require './env'
couch = require './couch'
flatfile = require './flatfile'
config = require 'config'
log = require '../log'

backends = [redis, consul, couch, env, flatfile]
datastore = null

module.exports =
    init: ->
        datastore = backends.find (backend) -> backend.detect()
        if not datastore
          throw 'No datastore backend found in the server configuration. Either define a backend
          or set a static list of routes by using the environment variable OCELOT_ROUTES or OCELOT_ROUTES_PATH.'

        datastore.init()

    getCachedRoutes: -> datastore.getCachedRoutes()
    getRoutes: -> Promise.resolve().then -> datastore.getRoutes()
    putRoute: (key, route) -> Promise.resolve().then -> datastore.putRoute(key, route)
    deleteRoute: (key) -> Promise.resolve().then -> datastore.deleteRoute(key)

    getCachedHosts: -> datastore.getCachedHosts()
    getHosts: -> Promise.resolve().then -> datastore.getHosts()
    putHost: (group, id, host) -> Promise.resolve().then -> datastore.putHost(group, id, host)
    deleteHost: (group, id) -> Promise.resolve().then -> datastore.deleteHost(group, id)
