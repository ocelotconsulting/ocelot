resolver = require './resolver'
rewrite = require './rewrite'
validate = require './auth/validate'
proxy = require './proxy'
exchange = require './auth/exchange'
refresh = require './auth/refresh'
response = require './response'
config = require 'config'
redirect = require './auth/redirect'
cors = require './cors'
headers = require './auth/headers'
tokenInfo = require './auth/token-info'
upgrade = require './upgrade'
URL = require 'url'

authenticateAndProxy = (px, req, res, route, url) ->
    authFulfilled = (authentication) ->
        if tokenInfo.accept req
            tokenInfo.complete route, res
        else
            headers.addAuth req, route, authentication
            proxy.request px, req, res, url

    authRejected = (authentication) ->
        if authentication.refresh
            refresh.token req, res, route
        else if authentication.redirect
            redirect.startAuthCode req, res, route
        else
            response.send res, 403, 'Authorization missing or invalid'

    validate.authentication(req, route).then authFulfilled, authRejected

handleDefaultRequest = (px, req, res) ->
    route = resolver.resolveRoute req.url, req.headers.host
    if not route?
#        if config.has 'route-not-found-url'
#            url = URL.parse config.get('route-not-found-url')
#            proxy.request px, req, res, url
#        else
        response.send res, 404, 'Route not found'
    else if exchange.accept req
        exchange.authCodeFlow req, res, route
    else
        url = rewrite.mapRoute req.url, route
        if url
            authenticateAndProxy px, req, res, route, url
        else
            response.send res, 404, 'No active URL for route'

module.exports =
    create: (px) ->
        (req, res) ->
            cors.setCorsHeaders req, res
            if cors.shortCircuit req then response.send res, 204
            else if upgrade.accept req then upgrade.complete req, res
            else handleDefaultRequest px, req, res
