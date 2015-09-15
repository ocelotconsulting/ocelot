Promise = require 'promise'
postman = require './postman'
config = require 'config'
cookies = require '../cookies'
client = config.get 'authentication.ping.validate.client'
secret = config.get 'authentication.ping.validate.secret'

# todo: call backend for url composition
getToken = (req, route) ->
    if req.headers.authorization and req.headers.authorization.toLowerCase().indexOf('bearer') > -1
        req.headers.authorization.split(' ')[1]
    else if route['cookie-name']
        cookies.parse(req)[route['cookie-name']]
    else null

module.exports =
    authentication: (req, route) ->
        new Promise((resolve, reject) ->
            if route['require-auth'] == false
                resolve {}
            else
                token = getToken(req, route)
                refreshTokenPresent = typeof cookies.parse(req)[route['cookie-name'] + '_rt'] != 'undefined'
                cookieAuthEnabled = route['cookie-name'] and route['cookie-name'].length > 0
                if !token
                    reject
                        refresh: refreshTokenPresent
                        redirect: cookieAuthEnabled
                else
                    validateQuery = 'grant_type=' + encodeURIComponent('urn:pingidentity.com:oauth2:grant_type:validate_bearer') + '&token=' + token
                    postman.postAs(validateQuery, client, secret).then ((result) ->
                        result.valid = true
                        resolve result
                    ), ->
                        reject
                            refresh: refreshTokenPresent
                            redirect: cookieAuthEnabled
        )