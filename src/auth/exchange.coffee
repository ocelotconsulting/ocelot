url = require 'url'
postman = require './postman'
headers = require './headers'
response = require '../response'

grantType = "authorization_code"

endsWith = (str, suffix) ->
    str.indexOf(suffix, str.length - suffix.length) != -1

getRedirectUrl = (query) ->
    redirectUrl = new Buffer(query.state, 'base64').toString('utf8').split('?')[0]
    redirectUrl = if endsWith redirectUrl, '/' then "#{redirectUrl}receive-auth-token" else "#{redirectUrl}/receive-auth-token"
    encodeURIComponent redirectUrl

module.exports =
    authCodeFlow: (req, res, route) ->
        {query} = url.parse req.url, true
        redirectUrl = getRedirectUrl query
        code = encodeURIComponent query.code
        exchangeQuery = "grant_type=#{grantType}&code=#{code}&redirect_uri=#{redirectUrl}"

        redirectToOriginalUri = (result) ->
            res.setHeader 'Location', new Buffer(query.state, 'base64').toString('utf8')
            headers.setAuthCookies(res, route, result).then ->
                response.send res, 307

        authCodeExchangeError = (err) ->
            console.log "Auth code exchange error for route #{route.route}: #{err}; for query #{exchangeQuery}"
            response.send res, 500, err

        postman.post(exchangeQuery, route).then redirectToOriginalUri, authCodeExchangeError
