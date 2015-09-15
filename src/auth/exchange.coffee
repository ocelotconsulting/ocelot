url = require 'url'
postman = require './postman'
headers = require './headers'

tryCode = (req, route) ->
    query = url.parse(req.url, true).query
    redirectUrl = new Buffer(query.state, 'base64').toString('utf8').split('?')[0] + '/receive-auth-token'
    redirectUrl = encodeURIComponent(redirectUrl)
    exchangeQuery = 'grant_type=authorization_code&code=' + query.code + '&redirect_uri=' + redirectUrl
    postman.post exchangeQuery, route

module.exports =
    code: (req, res, route) ->
        tryCode(req, route).then ((result) ->
            query = url.parse(req.url, true).query
            res.setHeader 'Location', new Buffer(query.state, 'base64').toString('utf8')
            headers.setAuthCookies res, route, result
            res.statusCode = 307
            res.end()
        ), (error) ->
            console.log 'Error during code exchange: ' + error + '; for url: ' + req.url
            res.statusCode = 500
            res.end()