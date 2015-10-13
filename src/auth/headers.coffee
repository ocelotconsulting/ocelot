_ = require 'underscore'
cookies = require '../cookies'
crypt = require './crypt'
wam = require '../backend/wam'

module.exports =
    setAuthCookies: (res, route, authentication) ->
        #todo: maybe hash incoming ip address along with cookie to prevent cross site scripting
        cookieName = route['cookie-name']
        cookieArray = [ "#{cookieName}=#{authentication.access_token}" ]
        wamPromise = if route['wam-legacy'] then wam.getWAMToken(authentication.access_token) else Promise.resolve(undefined)
        wamPromise.then((wamResult) ->
            if wamResult
                cookieArray[cookieArray.length] = "AXMSESSION=#{wamResult}"
            if authentication.refresh_token
                cookieArray[cookieArray.length] = "#{cookieName}_rt=#{crypt.encrypt(authentication.refresh_token, route['client-secret'])};HttpOnly"
            if authentication.id_token
                cookieArray[cookieArray.length] = "#{cookieName}_oidc=#{authentication.id_token}"

            cookiePath = route['cookie-path'] or "/#{route.route}"
            cookieArray = _.map(cookieArray, (item) ->
                "#{item}; path=#{cookiePath}"
            )
            res.setHeader 'Set-Cookie', cookieArray
            res
        )
    addAuth: (req, route, authentication) ->
        try
            userHeader = route['user-header']
            clientHeader = route['client-header']
            oidc = cookies.parse(req)[route['cookie-name'] + '_oidc']
            if authentication.valid and userHeader and oidc
                stringToParse = new Buffer(oidc.split('.')[1], 'base64').toString('utf8')
                oidcDecoded = JSON.parse(stringToParse)
                req.headers[userHeader] = oidcDecoded.sub
            if authentication.valid and clientHeader and authentication.client_id
                req.headers[clientHeader] = authentication.client_id
        catch ex
            console.log 'error adding user/client header: ' + ex + '; ' + ex.stack