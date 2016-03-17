_ = require 'underscore'
crypt = require './crypt'
wam = require '../backend/wam'
log = require '../log'
Promise = require 'promise'

module.exports =

    addCustomHeaders: (req, route) ->
        customHeaders = route['custom-headers'] or []
        for {key, value} in customHeaders
            req.headers[key] = value

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
                  ]).chain().compact().map((item) ->
                      "#{item}; path=#{cookiePath}"
                  )

            if route['cookie-domain']
                cookieChain = cookieChain.map((item) -> "#{item}; domain=#{route['cookie-domain']}")

            res.setHeader 'Set-Cookie', cookieChain.value()

    addAuth: (req, route, authentication) ->
        try
            updateHeader = (name, value) ->
                if value then req.headers[name] = value else delete req.headers[name]

            userInfo = JSON.stringify(authentication['user-info']) if authentication?['user-info']
            profile = JSON.stringify(authentication['profile']) if authentication?['profile']
            userHeader = route['user-header']
            clientHeader = route['client-header']
            if clientHeader then updateHeader clientHeader, authentication?.client_id
            if userHeader then updateHeader userHeader, (authentication?.claims?.sub or authentication?.access_token?.user_id)
            updateHeader 'user-info', userInfo
            updateHeader 'user-profile', profile
        catch ex
            log.error 'error adding user/client header: ' + ex + '; ' + ex.stack
