_ = require 'underscore'
crypt = require './crypt'
wam = require '../backend/wam'
log = require '../log'
Promise = require 'promise'

module.exports =

    #todo: wam sucks
    setAuthCookies: (res, route, authentication) ->
        wamPromise = if route['wam-legacy'] then wam.getWAMToken authentication.access_token else Promise.resolve()
        wamPromise.then (wamResult) ->
            cookieName = route['cookie-name']
            refreshTokenCookie = ->
                "#{cookieName}_rt=#{crypt.encrypt(authentication.refresh_token, route['client-secret'])};HttpOnly"

            cookiePath =
                if route['cookie-path']
                    route['cookie-path']
                else if route.route.indexOf("/") != -1
                    route.route.substring(route.route.indexOf("/"))
                else
                    "/"

            cookieChain = _([
                      "#{cookieName}=#{authentication.access_token}"
                      if wamResult then "AXMSESSION=#{wamResult}"
                      if authentication.refresh_token then refreshTokenCookie()
                      if authentication.id_token then "#{cookieName}_oidc=#{authentication.id_token}"
                  ]).chain().compact().map((item) ->
                      "#{item}; path=#{cookiePath}"
                  )

            if route['cookie-domain']
                cookieChain = cookieChain.map((item) -> "#{item}; domain=#{route['cookie-domain']}")

            res.setHeader 'Set-Cookie', cookieChain.value()

    addAuth: (req, route, authentication, cookies) ->
        try
            userHeader = route['user-header']
            clientHeader = route['client-header']

            updateHeader = (name, value) ->
                if value then req.headers[name] = value else delete req.headers[name]

            if clientHeader then updateHeader clientHeader, authentication?.client_id
            if userHeader then updateHeader userHeader, (authentication?.claims?.sub or authentication?.user_id)
            if not req.headers['oidc'] and route['cookie-name'] then updateHeader 'oidc', cookies["#{route['cookie-name']}_oidc"]

        catch ex
            log.error 'error adding user/client header: ' + ex + '; ' + ex.stack
