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

authFulfilled = (authentication) ->
    headers.addAuth @req, @route, authentication
    proxy.request @px, @req, @res, @url

authRejected = (authentication) ->
    if authentication.refresh
        refresh.token @req, @res, @route
    else if authentication.redirect
        redirect.startAuthCode @req, @res, @route
    else
        response.send @res, 403, 'Authorization missing or invalid'

module.exports =
    create: (px) ->
        (req, res) ->
            console.log req.headers

            cors.setCorsHeaders req, res
            if cors.preflight(req)
                response.send res, 204
            else
                route = resolver.resolveRoute(req.url, req.headers.host)
                if route == null
                    response.send res, 404, 'Route not found'
                else if req.url.indexOf('receive-auth-token') > -1
                    exchange.authCodeFlow req, res, route
                else
                    url = rewrite.mapRoute(req.url, route)
                    if url == null
                        response.send res, 404, 'No active URL for route'
                    else
                        newThis = { req: req, res: res, route: route, px: px, url: url }
                        validate.authentication(req, route).then authFulfilled.bind(newThis), authRejected.bind(newThis)