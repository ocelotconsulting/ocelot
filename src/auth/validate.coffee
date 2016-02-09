_ = require 'underscore'
postman = require './postman'
config = require 'config'
parseCookies = require '../parseCookies'
cache = require 'memory-cache'
log = require '../log'
Promise = require 'promise'

oauth = require './oauth'
oidc = require './oidc'

exports.authentication = (req, route, cookies) ->
    if not route?['require-auth']
        Promise.resolve()
    else
        oauth.getToken(req, route, cookies).then (oauthToken) ->
            oauth.validate(oauthToken).then (validationResult) ->
                oidcToken = oidc.getToken req, cookies
                if oidcToken
                    oidc.validate(oidcToken).then (claims) ->
                        Object.assign(validationResult, {claims: claims})
                else
                    validationResult
