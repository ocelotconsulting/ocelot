response = require '../response'
config = require 'config'

addQueryParam = (key, value) ->
    if value then '&' + key + '=' + encodeURIComponent(value) else ''

module.exports =
    # todo: remove references to ping, call auth backend
    toAuthServer: (req, res, route) ->
        origUrl = 'http://' + req.headers.host + req.url
        redirectUrl = origUrl + '/receive-auth-token'
        redirectUrl = redirectUrl.split('?')[0]
        state = new Buffer(origUrl).toString('base64')
        client = route['client-id']
        authServer = config.get('authentication.ping.host')
        scope = route['oidc-scope']
        location = authServer + '/as/authorization.oauth2?' + 'response_type=code' + addQueryParam('client_id', client) + addQueryParam('redirect_uri', redirectUrl) + addQueryParam('state', state) + addQueryParam('scope', scope)
        res.setHeader 'Location', location
        response.send res, 307
    refreshPage: (req, res) ->
        origUrl = 'http://' + req.headers.host + req.url
        res.setHeader 'Location', origUrl
        response.send res, 307