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

redirectProtocol = (req) ->
    settingPath = 'default-protocol'
    if req.headers['x-forwarded-proto']? then req.headers['x-forwarded-proto']
    else if config.has settingPath then config.get settingPath
    else 'http'

authServer = config.get 'authentication.ping.host'

endsWith = (str, suffix) ->
    str.indexOf(suffix, str.length - suffix.length) != -1

module.exports =
    # todo: remove references to ping, call auth backend
    startAuthCode: (req, res, route) ->
        origUrl = "#{redirectProtocol(req)}://#{req.headers.host}#{req.url}"
        redirect_uri = if endsWith origUrl, '/' then "#{origUrl}receive-auth-token" else "#{origUrl}/receive-auth-token"
        redirect_uri = redirect_uri.split('?')[0]
        state = new Buffer(origUrl).toString 'base64'
        client_id = route['client-id']
        scope = route['oidc-scope']
        location = buildUrl "#{authServer}/as/authorization.oauth2", {response_type: 'code', client_id, redirect_uri, state, scope}
        res.setHeader 'Location', location
        response.send res, 307
    refreshPage: (req, res) ->
        origUrl = "#{redirectProtocol(req)}://#{req.headers.host}#{req.url}"
        res.setHeader 'Location', origUrl
        response.send res, 307
    upgrade: (req, res) ->
        url = "https://#{req.headers.host}#{req.url}"
        res.setHeader 'Location', url
        response.send res, 307