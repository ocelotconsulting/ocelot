url = require 'url'
postman = require './postman'
setCookies = require './set-cookies'
response = require '../response'
log = require '../log'

grantType = "authorization_code"

endsWith = (str, suffix) ->
    str.indexOf(suffix, str.length - suffix.length) != -1

getRedirectUrl = (query) ->
    redirectUrl = new Buffer(query.state, 'base64').toString('utf8').split('?')[0]
    if endsWith redirectUrl, '/' then "#{redirectUrl}receive-auth-token" else "#{redirectUrl}/receive-auth-token"

module.exports =
    accept: (req) ->
        endsWith(req.url.split('?')[0], 'receive-auth-token')
    authCodeFlow: (req, res, route) ->
        {query} = url.parse req.url, true

        formData =
            grant_type: grantType
            code: query.code
            redirect_uri: getRedirectUrl query

        redirectToOriginalUri = (result) ->
            log.debug "Exchanged code #{query.code} for route #{route.route}"
            res.setHeader 'Location', new Buffer(query.state, 'base64').toString('utf8')
            setCookies.setAuthCookies(res, route, result).then ->
                response.send res, 307

        authCodeExchangeError = (err) ->
              log.debug "Auth code exchange error for route #{route.route}: #{err}; for query #{JSON.stringify(formData)}"
              response.send res, 500, err

        log.debug "Attempting auth code exchange for route #{route.route} query #{JSON.stringify(formData)}"
        postman.post(formData, route)
            .then redirectToOriginalUri, authCodeExchangeError
