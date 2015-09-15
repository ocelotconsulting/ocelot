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

module.exports =
    create: (px) ->
        host = config.get('route.host')
        presumeHost = (req) ->

        if host != 'auto'
            presumeHost = (req) ->
                req.headers.host = host

        (req, res) ->
            cors.setCorsHeaders req, res
            if cors.preflight(req)
                response.send res, 204
                return
            presumeHost req
            route = resolver.resolveRoute(req.url)
            if route == null
                response.send res, 404, 'Route not found'
            else if req.url.indexOf('receive-auth-token') > -1
                exchange.code req, res, route
            else
                url = rewrite.mapRoute(req.url, route)
                if url == null
                    response.send res, 404, 'No active URL for route'
                else
                    validate.authentication(req, route).then ((authentication) ->
                        headers.addAuth req, route, authentication
                        proxy.request px, req, res, url
                    ), (authentication) ->
                        if authentication.refresh
                            refresh.token req, res, route
                        else if authentication.redirect
                            redirect.toAuthServer req, res, route
                        else
                            response.send res, 403, 'Authorization missing or invalid'