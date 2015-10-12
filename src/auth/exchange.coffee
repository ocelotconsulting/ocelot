url = require 'url'
postman = require './postman'
headers = require './headers'

requestAuthCode = (req, route) ->
    query = url.parse(req.url, true).query
    redirectUrl = new Buffer(query.state, 'base64').toString('utf8').split('?')[0] + '/receive-auth-token'
    redirectUrl = encodeURIComponent(redirectUrl)
    exchangeQuery = 'grant_type=authorization_code&code=' + query.code + '&redirect_uri=' + redirectUrl
    postman.post exchangeQuery, route

redirectToOriginalUri = (result) ->
    query = url.parse(this.req.url, true).query
    this.res.setHeader 'Location', new Buffer(query.state, 'base64').toString('utf8')
    headers.setAuthCookies this.res, this.route, result
    .then(=>
        this.res.statusCode = 307
        this.res.end()
    )

authCodeExchangeError = (error) ->
    console.log 'Error during code exchange: ' + error + '; for url: ' + this.req.url
    this.res.statusCode = 500
    this.res.end()

module.exports =
    authCodeFlow: (req, res, route) ->
        newThis = {req: req, res: res, route: route}
        requestAuthCode(req, route).then redirectToOriginalUri.bind(newThis), authCodeExchangeError.bind(newThis)