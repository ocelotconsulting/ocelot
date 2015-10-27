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

authenticateAndProxy = (px, req, res, route, url) ->
    authFulfilled = (authentication) ->
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
        response.send res, 404, 'Route not found'
    else if req.url.indexOf('receive-auth-token') > -1
        exchange.authCodeFlow req, res, route
    else
        url = rewrite.mapRoute req.url, route
        if url
            authenticateAndProxy px, req, res, route, url
        else
            response.send res, 404, 'No active URL for route'

upgradeConnection = (req) ->
    console.log("enforce https: #{config.get('enforce-https')}")
    console.log("x-forwarded-proto: #{req.headers['x-forwarded-proto']}")
    console.log("secure connection: #{req.connection.secure}")
    upgrade = config.get('enforce-https') and req.headers['x-forwarded-proto'] != 'https' and not req.connection.secure?
    console.log("upgrade connection: #{upgrade}")
    upgrade


module.exports =
    create: (px) ->
        (req, res) ->
            cors.setCorsHeaders req, res
            if cors.preflight req then response.send res, 204
            else if upgradeConnection req then redirect.upgrade req, res
            else handleDefaultRequest px, req, res
