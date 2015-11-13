url = require 'url'
postman = require './postman'
headers = require './headers'
response = require '../response'

endsWith = (str, suffix) ->
    str.indexOf(suffix, str.length - suffix.length) != -1

module.exports =
    authCodeFlow: (req, res, route) ->
        {query} = url.parse req.url, true
        redirectUrl = new Buffer(query.state, 'base64').toString('utf8').split('?')[0]
        redirectUrl = if endsWith redirectUrl, '/' then "#{redirectUrl}receive-auth-token" else "#{redirectUrl}/receive-auth-token"
        redirectUrl = encodeURIComponent(redirectUrl)
        exchangeQuery = "grant_type=authorization_code&code=#{query.code}&redirect_uri=#{redirectUrl}"

        redirectToOriginalUri = (result) ->
            res.setHeader 'Location', new Buffer(query.state, 'base64').toString('utf8')
            headers.setAuthCookies(res, route, result).then ->
                response.send res, 307

        authCodeExchangeError = (err) ->
            response.send res, 500, err

        postman.post(exchangeQuery, route).then redirectToOriginalUri, authCodeExchangeError