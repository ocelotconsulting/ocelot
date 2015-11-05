http = require 'http'
facade = require './backend/facade.coffee'
uri = require 'url'
_ = require 'underscore'

getUrlStrStripLeadingSlash = (urlStr) ->
    path = uri.parse(urlStr).pathname
    if path.indexOf('/') is 0 then path.substring 1 else path

findRouteByHost = (host) ->
    if host.indexOf('.') > 0 then findRoute host.split('.')[0]

findRoute = (key) ->
    _(facade.getRoutes()).find (route) -> route.route is key

findRouteByPath = (url, pathDepth = 3) ->
    if pathDepth is 0
        findRoute 'root'
    else
        routePath = getUrlStrStripLeadingSlash(url).split('/', pathDepth).join '/'
        findRoute(routePath) or findRouteByPath(url, pathDepth - 1)

facade.init()

module.exports =
    resolveRoute: (url, host) ->
        closestRoute = findRouteByHost(host) or findRouteByPath(url)
        services = facade.getServices()
        closestRoute?.instances = _(closestRoute.services).chain().map((service) ->
            [service, services[service]]
        ).object().value()
        closestRoute