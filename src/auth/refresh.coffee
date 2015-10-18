postman = require './postman'
redirect = require './redirect'
parseCookies = require '../parseCookies'
headers = require './headers'
crypt = require './crypt'
_ = require 'underscore'

#todo: call backend for url composition
module.exports =
    token: (req, res, route) ->
        tryRefresh = ->
            cookies = parseCookies req
            cookieName = "#{route['cookie-name']}_rt"
            refreshToken = crypt.decrypt cookies[cookieName], route['client-secret']
            postman.post "grant_type=refresh_token&refresh_token=#{refreshToken}", route

        doRefresh = (result) ->
            headers.setAuthCookies res, route, result
            .then (result) ->
                redirect.refreshPage req, result

        refreshError = (error) ->
            console.log error
            redirect.startAuthCode req, res, route

        tryRefresh().then doRefresh, refreshError
