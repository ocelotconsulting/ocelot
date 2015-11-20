consul = require './consul'
redis = require './redis'
config = require 'config'
datastore = undefined
jwks = require './jwks'

# todo: get rid of this module?
module.exports =
    init: ->
        if consul.detect()
            datastore = consul
        else if redis.detect()
            datastore = redis
        else
            throw 'no datastore backend found in configuration'

        datastore.init()

        if not config.has 'jwks.url' then throw 'no jwks url found in configuration'
        # jwks.init is periodically throwing Error: getaddrinfo EAI_AGAIN errors causing all of ocelot to die, jwks isn't even being used in the code base.
        # jwks.init()

    getCachedRoutes: -> datastore.getCachedRoutes()
    getRoutes: -> datastore.getRoutes()
    putRoute: (key, route) -> datastore.putRoute(key, route)
    deleteRoute: (key) -> datastore.deleteRoute(key)

    getCachedHosts: -> datastore.getCachedHosts()
    getHosts: -> datastore.getHosts()
    putHost: (group, id, host) -> datastore.putHost(group, id, host)
    deleteHost: (group, id) -> datastore.deleteHost(group, id)

    getJWKS: -> jwks.getKeys

    reloadData: ->
        datastore.reloadData()
        jwks.reloadData()
