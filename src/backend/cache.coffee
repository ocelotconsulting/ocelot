consul = require './consul'
config = require 'config'
backend = undefined

module.exports =
    initCache: ->
        if config.has('backend.consul')
            backend = consul
        else
            throw 'no backend found in configuration'
        backend.initCache()
    getRoutes: ->
        backend.getRoutes()
    getServices: ->
        backend.getServices()
    reloadData: ->
        backend.reloadData()