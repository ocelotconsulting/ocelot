Promise = require 'promise'
postman = require './postman'
config = require 'config'
cookies = require '../cookies'
client = config.get 'authentication.ping.validate.client'
secret = config.get 'authentication.ping.validate.secret'
_ = require 'underscore'
jwks = require '../backend/jwks'

# todo: call backend for url composition
getToken = (req, route) ->
    returnVal = {}
    if req.headers.authorization and req.headers.authorization.toLowerCase().indexOf('bearer') > -1
        returnVal['OAuth'] = req.headers.authorization.split(' ')[1]
    else if route['cookie-name']
        returnVal['OAuth'] = cookies.parse(req)[route['cookie-name']]
    else returnVal['OAuth'] = null

    if route['cookie-name']
        returnVal['OIDC'] = cookies.parse(req)[route['cookie-name'] + '_oidc']
    else returnVal['OIDC'] = null
    returnVal

module.exports =
    authentication: (req, route) ->
        if route['require-auth'] == false
            Promise.resolve {}
        else
            token = getToken(req, route)
            refreshTokenPresent = typeof cookies.parse(req)[route['cookie-name'] + '_rt'] != 'undefined'
            cookieAuthEnabled = route['cookie-name'] and route['cookie-name'].length > 0
            rejectData = {refresh: refreshTokenPresent, redirect: cookieAuthEnabled}
            if !token['OAuth']
                Promise.reject rejectData
            else
#                console.log "Checking #{token['OIDC']}"
#                    oidcValidated = jwks.validateToken(token['OIDC'])
                oidcValidated = false
                validateQuery = 'grant_type=' + encodeURIComponent('urn:pingidentity.com:oauth2:grant_type:validate_bearer') + '&token=' + token['OAuth']
                postman.postAs(validateQuery, client, secret).then((oAuthValidateResult) ->
                    Promise.resolve(_.extend(oAuthValidateResult, {valid: true, oidcValid: oidcValidated}))
                )
                .catch((err) ->
                    console.log "Had an error #{err}"
                    Promise.reject _.extend(rejectData, {oidcValid: oidcValidated})
                )
