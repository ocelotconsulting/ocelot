_ = require 'underscore'
postman = require './postman'
config = require 'config'
parseCookies = require '../parseCookies'
jwks = require '../backend/jwks'
cache = require 'memory-cache'
log = require '../log'

client = config.get 'authentication.ping.validate.client'
secret = config.get 'authentication.ping.validate.secret'
grantType = encodeURIComponent 'urn:pingidentity.com:oauth2:grant_type:validate_bearer'

validateToken = (token) ->
    cachedValidation = cache.get token
    if cachedValidation
        Promise.accept cachedValidation
    query = "grant_type=#{grantType}&token=#{token}"
    postman.postAs(query, client, secret)

getCookieToken = (route) ->
    cookieName = route['cookie-name']
    token = cookieName? and parseCookies(req)[cookieName]
    if not token?
        Promise.reject()
    else
        Promise.accept(token)

getBearerToken = (req) ->
    {authorization} = req.headers
    token = if authorization? and authorization.slice(0, 7).toLowerCase() is 'bearer ' then authorization.slice 7
    if not token?
        Promise.reject()
    else
        Promise.accept(token)

exports.authentication = (req, route) ->
    if route? and not route?['require-auth']
        Promise.resolve()
    else
        authCodeFlowEnabled = false
        refreshTokenFound = false
        getBearerToken(req)
        .catch () ->
            getCookieToken(route)
            .then (token) ->
                authCodeFlowEnabled = true
                refreshTokenFound = parseCookies(req)["#{route['cookie-name']}_rt"]?
                token
        .then (token) ->
            validateToken(token)
            .then (validateResult) ->
                authentication = _(validateResult).extend {valid: true}
                cache.put token, authentication, 60000
                authentication
            .catch (err) ->
                log.error "Validate error for route #{route.route}: #{err}; for query #{query}"
                Promise.reject {refresh: refreshTokenFound, redirect: authCodeFlowEnabled}
        .catch () ->
            Promise.reject {refresh: refreshTokenFound, redirect: authCodeFlowEnabled}