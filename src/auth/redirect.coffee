response = require '../response'
config = require 'config'

buildUrl = (base, params) ->
    url = base
    separator = '?'

    addParam = (name, value) ->
        if value
            url += "#{separator}#{name}=#{encodeURIComponent value}"
            separator = '&'

    addParam name, value for name, value of params
    url

redirectProtocol = do ->
    settingPath = 'authentication.ping.redirect-protocol'
    if config.has settingPath then config.get settingPath else 'http:'

authServer = config.get 'authentication.ping.host'

module.exports =
    # todo: remove references to ping, call auth backend
    startAuthCode: (req, res, route) ->
        origUrl = "#{redirectProtocol}//#{req.headers.host}#{req.url}"
        redirect_uri = "#{origUrl}/receive-auth-token"
        redirect_uri = redirect_uri.split('?')[0]
        state = new Buffer(origUrl).toString 'base64'
        client_id = route['client-id']
        scope = route['oidc-scope']
        location = buildUrl "#{authServer}/as.authorization.oauth2", {response_type: 'code', client_id, redirect_uri, state, scope}
        res.setHeader 'Location', location
        response.send res, 307
    refreshPage: (req, res) ->
        origUrl = "http://#{req.headers.host}#{req.url}"
        res.setHeader 'Location', origUrl
        response.send res, 307