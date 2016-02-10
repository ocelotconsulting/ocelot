postman = require './postman'
redirect = require './redirect'
headers = require './headers'
crypt = require './crypt'
log = require '../log'
grantType = "refresh_token"

module.exports =
    accept: (route, cookies, auth)->
        route['require-auth'] and route['cookie-name'] and cookies["#{route['cookie-name']}_rt"]? and not auth?.invalid_oidc

    token: (req, res, route, cookies) ->
        console.log 'going to refresh cookie for ', route.route
        cookieName = "#{route['cookie-name']}_rt"

        refreshToken = crypt.decrypt cookies[cookieName], route['client-secret']
        formData =
            grant_type: grantType
            refresh_token: refreshToken

        tryRefreshToken = ->
            postman.post formData, route

        browserRefresh = (result) ->
            headers.setAuthCookies res, route, result
            .then () ->
                redirect.refreshPage req, res

        beginAuthCodeFlow = (err) ->
            log.error "Refresh error for route #{route.route} when using cookie #{cookieName}: #{err}; for query #{formData}"
            redirect.startAuthCode req, res, route

        tryRefreshToken().then browserRefresh, beginAuthCodeFlow
