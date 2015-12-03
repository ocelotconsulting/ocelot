url = require 'url'
postman = require './postman'
headers = require './headers'
response = require '../response'
log = require '../log'

grantType = "authorization_code"

endsWith = (str, suffix) ->
    str.indexOf(suffix, str.length - suffix.length) != -1

getRedirectUrl = (query) ->
    redirectUrl = new Buffer(query.state, 'base64').toString('utf8').split('?')[0]
    if endsWith redirectUrl, '/' then "#{redirectUrl}receive-auth-token" else "#{redirectUrl}/receive-auth-token"

module.exports =
    authCodeFlow: (req, res, route) ->
        {query} = url.parse req.url, true
        redirectUrl = getRedirectUrl query
        code = query.code
        formData =
            grant_type: grantType
            code: code
            redirect_uri: redirectUrl

        redirectToOriginalUri = (result) ->
            log.debug "Exchanged code for token for route #{route.route}; server response #{JSON.stringify result}"
            res.setHeader 'Location', new Buffer(query.state, 'base64').toString('utf8')
            headers.setAuthCookies(res, route, result).then ->
                log.debug "Completing the exchange for route #{route.route} with headers #{JSON.stringify res.headers}"
                response.send res, 307

        authCodeExchangeError = (err) ->
            log.debug "Auth code exchange error for route #{route.route}: #{err}; for query #{formData}"
            response.send res, 500, err

        log.debug "Attempting auth code exchange for route #{route.route} query #{formData}"
        postman.post(formData, route).then redirectToOriginalUri, authCodeExchangeError
