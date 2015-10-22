http = require 'http'
cache = require './backend/cache'
uri = require 'url'
_ = require 'underscore'

getUrlStrStripLeadingSlash = (urlStr) ->
    path = uri.parse(urlStr).pathname
    if path.indexOf('/') is 0 then path.substring 1 else path

findRouteByHost = (host) ->
    if host.indexOf('.') > 0 then findRoute host.split('.')[0]

findRoute = (key) ->
    _(cache.getRoutes()).find (route) -> route.route is key

findRouteByPath = (url, pathDepth = 3) ->
    if pathDepth is 0
        findRoute 'root'
    else
        routePath = getUrlStrStripLeadingSlash(url).split('/', pathDepth).join '/'
        findRoute(routePath) or findRouteByPath(url, pathDepth - 1)

cache.initCache()

module.exports =
    resolveRoute: (url, host) ->
        closestRoute = findRouteByHost(host) or findRouteByPath(url)
        services = cache.getServices()
        closestRoute?.instances = _(closestRoute.services).chain().map((service) ->
            [service, services[service]]
        ).object().value()
        closestRoute