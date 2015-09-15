postman = require './postman'
redirect = require './redirect'
cookies = require '../cookies'
headers = require './headers'
crypt = require './crypt'

#todo: call backend for url composition
tryRefresh = (req, route) ->
    refreshQuery = 'grant_type=refresh_token&refresh_token=' + crypt.decrypt(cookies.parse(req)[route['cookie-name'] + '_rt'], route['client-secret'])
    postman.post refreshQuery, route

module.exports
    token: (req, res, route) ->
        tryRefresh(req, route).then ((result) ->
            headers.setAuthCookies res, route, result
            redirect.refreshPage req, res
        ), (error) ->
            console.log error
            redirect.toAuthServer req, res, route