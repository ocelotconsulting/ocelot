postman = require './postman'
redirect = require './redirect'
parseCookies = require '../parseCookies'
headers = require './headers'
crypt = require './crypt'
_ = require 'underscore'
log = require '../log'
grantType = "refresh_token"

module.exports =
    token: (req, res, route) ->
        cookies = parseCookies req
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
