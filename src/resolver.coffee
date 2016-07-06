http = require 'http'
facade = require './backend/facade.coffee'
_ = require 'underscore'

findRoute = (key) ->
  _(facade.getCachedRoutes()).find (route) -> route.route is key

findRouteByPath = (url, pathDepth = 4) ->
  if pathDepth == 0
    null
  else
    key = url.split('/', pathDepth).join '/'
    findRoute(key) or findRoute('www.' + key) or findRouteByPath(key, pathDepth - 1)

module.exports =
  resolveRoute: (url, host) ->
    url = url.split('?')[0]
    closestRoute = findRouteByPath("#{host}#{url}")
    services = facade.getCachedHosts()
    closestRoute?.instances = _(closestRoute.services).chain().map((service) ->
      [service, services[service]]
    ).object().value()
    closestRoute
