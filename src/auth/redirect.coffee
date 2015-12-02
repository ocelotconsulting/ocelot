response = require '../response'
config = require 'config'
config = require 'config'
log = require '../log'

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

authUrl = config.get 'authentication.ping.auth-endpoint'

endsWith = (str, suffix) ->
    str.indexOf(suffix, str.length - suffix.length) != -1

module.exports =
    startAuthCode: (req, res, route) ->
        origUrl = "#{redirectProtocol(req)}://#{req.headers.host}#{req.url}"
        state = new Buffer(origUrl).toString 'base64'
        redirect_uri = origUrl.split('?')[0]
        redirect_uri = if endsWith redirect_uri, '/' then "#{redirect_uri}receive-auth-token" else "#{redirect_uri}/receive-auth-token"
        client_id = route['client-id']
        scope = route['oidc-scope']
        location = buildUrl authUrl, {response_type: 'code', client_id, redirect_uri, state, scope}
        res.setHeader 'Location', location
        log.debug "Redirecting request #{origUrl} to #{location}"
        response.send res, 307
    refreshPage: (req, res) ->
        origUrl = "#{redirectProtocol(req)}://#{req.headers.host}#{req.url}"
        res.setHeader 'Location', origUrl
        log.debug "Refreshing current page #{origUrl}"
        response.send res, 307
    upgrade: (req, res) ->
        url = "https://#{req.headers.host}#{req.url}"
        res.setHeader 'Location', url
        response.send res, 307