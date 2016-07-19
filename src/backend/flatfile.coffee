log = require '../log'
routes = []

module.exports =
  detect: ->
    process.env.OCELOT_ROUTES? or process.env.OCELOT_ROUTES_PATH?

  init: ->
    fs = require 'fs'
    configPath =
      if process.env.OCELOT_ROUTES_PATH
        process.env.OCELOT_ROUTES_PATH
      else
        home = process.env.HOME or '/'
        home + '/.ocelot_routes'

    fs.stat configPath, (err, stats) ->
      staticRouteConfig = null
      if err or not stats.isFile
        log.debug 'No static route file found at', configPath
      else
        try
          routes=JSON.parse fs.readFileSync(configPath, 'utf8')
          log.debug 'Found static routes configuration'
        catch e
          log.debug 'Could not read or parse static route file', e

  getCachedRoutes: -> routes
  getRoutes: -> routes
  putRoute: (id, route) -> throw new Error 'Method not supported'
  deleteRoute: (id) -> throw new Error 'Method not supported'

  getCachedHosts: -> {}
  getHosts: -> {}
  putHost: (group, id, host) -> throw new Error 'Method not supported'
  deleteHost: (group, id) -> throw new Error 'Method not supported'
