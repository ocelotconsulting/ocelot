_ = require 'underscore'
postman = require './postman'
config = require 'config'
parseCookies = require '../parseCookies'
jwks = require '../backend/jwks'
cache = require 'memory-cache'

client = config.get 'authentication.ping.validate.client'
secret = config.get 'authentication.ping.validate.secret'
grantType = encodeURIComponent 'urn:pingidentity.com:oauth2:grant_type:validate_bearer'

# todo: call backend for url composition
exports.authentication = (req, route) ->
    if route['require-auth'] is false
        Promise.resolve {}
    else
        cookieName = route['cookie-name']
        cookieAuthEnabled = cookieName?
        cookies = cookieAuthEnabled and parseCookies req
        refreshTokenPresent = cookieAuthEnabled and cookies["#{cookieName}_rt"]?
        {authorization} = req.headers

        token = if authorization and authorization.slice(0, 7).toLowerCase() is 'bearer '
            authorization.slice 7
        else if cookieAuthEnabled
            cookies[cookieName]

        reject = (oidcValid = false) ->
            Promise.reject {refresh: refreshTokenPresent, redirect: cookieAuthEnabled, oidcValid}

        if not token
            reject()
        else
    #    oidcValid = if cookieAuthEnabled
    #        oidc = reqCookies["#{cookieName}_oidc"]
    #        console.log "Checking #{oidc}"
    #        jwks.validateToken oidc
    #    else
    #        false
            oidcValid = false

            cachedValidation = cache.get token
            if cachedValidation
                Promise.accept cachedValidation
            else
                postman.postAs("grant_type=#{grantType}&token=#{token}", client, secret)
                .then((oAuthValidateResult) ->
                    authentication = _(oAuthValidateResult).extend {valid: true, oidcValid}
                    cache.put token, authentication, 60000
                    authentication
                )
                .catch (error) ->
                    console.log "Had an error #{error}"
                    reject oidcValid