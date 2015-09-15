http = require 'http'
cache = require './backend/cache'
uri = require 'url'
_ = require 'underscore'

findRouteByHost = (host) ->
    if host.indexOf('.') > 0
        route = findRoute(host.split('.')[0])
        if typeof route != 'undefined'
            return route
    null

findRouteByPath = (url) ->
    pathDepth = 3
    while pathDepth >= 0
        routePath = if pathDepth == 0 then 'root' else getUrlStrStripLeadingSlash(url).split('/', pathDepth).join('/')
        route = findRoute(routePath)
        if typeof route != 'undefined'
            return route
        pathDepth--
    null

findRoute = (key) ->
    _.find cache.getRoutes(), (route) ->
        route.route == key

getUrlStrStripLeadingSlash = (urlStr) ->
    path = uri.parse(urlStr).pathname
    if path.indexOf('/') == 0 then path.substring(1) else path

cache.initCache()

module.exports =
    resolveRoute: (url, host) ->
        closestRoute = findRouteByHost(host) or findRouteByPath(url)
        if closestRoute != null
            closestRoute.instances = {}
            _.each closestRoute.services, (service) ->
                closestRoute.instances[service] = cache.getServices()[service]
        closestRoute