url = require 'url'
postman = require './postman'
headers = require './headers'

module.exports =
    authCodeFlow: (req, res, route) ->
        {query} = url.parse req.url, true
        redirectUrl = encodeURIComponent(new Buffer(query.state, 'base64').toString('utf8').split('?')[0] + '/receive-auth-token')
        exchangeQuery = "grant_type=authorization_code&code=#{query.code}&redirect_uri=#{redirectUrl}"

        redirectToOriginalUri = (result) ->
            res.setHeader 'Location', new Buffer(query.state, 'base64').toString('utf8')
            headers.setAuthCookies(res, route, result).then ->
                res.statusCode = 307
                res.end()

        authCodeExchangeError = ->
            res.statusCode = 500
            res.end()

        postman.post(exchangeQuery, route).then redirectToOriginalUri, authCodeExchangeError