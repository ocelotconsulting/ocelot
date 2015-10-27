_ = require 'underscore'
crypt = require './crypt'
wam = require '../backend/wam'
parseCookies = require '../parseCookies'

module.exports =
    setAuthCookies: (res, route, authentication) ->
        #todo: maybe hash incoming ip address along with cookie to prevent cross site scripting
        wamPromise = if route['wam-legacy'] then wam.getWAMToken authentication.access_token else Promise.resolve()
        wamPromise.then (wamResult) ->
            cookieName = route['cookie-name']
            refreshTokenCookie = ->
                "#{cookieName}_rt=#{crypt.encrypt(authentication.refresh_token, route['client-secret'])};HttpOnly"
            cookiePath = route['cookie-path'] or "/#{route.route}"
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
    addAuth: (req, route, authentication) ->
        try
            userHeader = route['user-header']
            clientHeader = route['client-header']
            oidc = parseCookies(req)[route['cookie-name'] + '_oidc']
            if authentication.valid and userHeader and oidc
                stringToParse = new Buffer(oidc.split('.')[1], 'base64').toString('utf8')
                oidcDecoded = JSON.parse(stringToParse)
                req.headers[userHeader] = oidcDecoded.sub
            if authentication.valid and clientHeader and authentication.client_id
                req.headers[clientHeader] = authentication.client_id
        catch ex
            console.log 'error adding user/client header: ' + ex + '; ' + ex.stack