postman = require './postman'
redirect = require './redirect'
parseCookies = require '../parseCookies'
headers = require './headers'
crypt = require './crypt'
_ = require 'underscore'
Log = require 'log'
log = new Log

grantType = "refresh_token"

#todo: call backend for url composition
module.exports =
    token: (req, res, route) ->
        cookies = parseCookies req
        cookieName = "#{route['cookie-name']}_rt"
        refreshToken = crypt.decrypt cookies[cookieName], route['client-secret']
        query = "grant_type=#{grantType}&refresh_token=#{refreshToken}"

        tryRefresh = ->
            postman.post query, route

        doRefresh = (result) ->
            headers.setAuthCookies res, route, result
            .then () ->
                redirect.refreshPage req, res

        refreshError = (err) ->
            log.debug "Refresh error for route #{route.route} when using cookie #{cookieName}: #{err}; for query #{query}"
            redirect.startAuthCode req, res, route

        tryRefresh().then doRefresh, refreshError
