_ = require 'underscore'
postman = require './postman'
config = require 'config'
parseCookies = require '../parseCookies'
jwks = require '../backend/jwks'
cache = require 'memory-cache'
log = require '../log'
Promise = require 'promise'

client = config.get 'authentication.validation-client'
secret = config.get 'authentication.validation-secret'
grantType = 'urn:pingidentity.com:oauth2:grant_type:validate_bearer'

validateToken = (token) ->
    cachedValidation = cache.get token
    if cachedValidation
        Promise.resolve cachedValidation
    else
        formData =
            grant_type: grantType
            token: token
        postman.postAs(formData, client, secret)

getCookieToken = (req, route) ->
    cookieName = route['cookie-name']
    token = cookieName? and parseCookies(req)[cookieName]

    if not token?
        Promise.reject()
    else
        Promise.resolve(token)

getBearerToken = (req) ->
    {authorization} = req.headers
    token = if authorization? and authorization.slice(0, 7).toLowerCase() is 'bearer ' then authorization.slice 7
    if not token?
        Promise.reject()
    else
        Promise.resolve(token)

exports.authentication = (req, route) ->
    if route and not route['require-auth']
        Promise.resolve()
    else
        authCodeFlowEnabled = false
        refreshTokenFound = false
        getBearerToken(req)
        .catch () ->
            authCodeFlowEnabled = route['cookie-name']?
            refreshTokenFound = parseCookies(req)["#{route['cookie-name']}_rt"]?
            getCookieToken(req, route)
        .then (token) ->
            validateToken(token)
            .then (validateResult) ->
                authentication = _(validateResult).extend {valid: true}
                cache.put token, authentication, 60000
                authentication
            .catch (err) ->
                log.error "Validate error for route #{route.route}: #{err}; for query #{query}"
                Promise.reject()
        .catch () ->
            Promise.reject {refresh: refreshTokenFound, redirect: authCodeFlowEnabled}