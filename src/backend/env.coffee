redis = require 'redis'
config = require 'config'
cron = require 'node-crontab'
{client, routes, hosts} = {}
hostRegex = /(.+)\/(.+)/
log = require '../log'
Promise = require 'promise'

routes = []

module.exports =
  detect: ->
    process.env.OCELOT_ROUTES?

  init: ->
    routes = JSON.parse(process.env.OCELOT_ROUTES)

  getCachedRoutes: -> routes
  getRoutes: -> routes
  putRoute: (id, route) -> throw 'Method not supported'
  deleteRoute: (id) -> throw 'Method not supported'

  getCachedHosts: -> {}
  getHosts: -> {}
  putHost: (group, id, host) -> throw 'Method not supported'
  deleteHost: (group, id) -> throw 'Method not supported'
