routes = []

module.exports =
  detect: ->
    process.env.OCELOT_ROUTES?

  init: ->
    routes = JSON.parse(process.env.OCELOT_ROUTES)

  getCachedRoutes: -> routes
  getRoutes: -> routes
  putRoute: (id, route) -> throw new Error 'Method not supported'
  deleteRoute: (id) -> throw new Error 'Method not supported'

  getCachedHosts: -> {}
  getHosts: -> {}
  putHost: (group, id, host) -> throw new Error 'Method not supported'
  deleteHost: (group, id) -> throw new Error 'Method not supported'
