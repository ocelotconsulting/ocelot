log = require '../log'
config = require 'config'
user = require './user'

module.exports =
    addCustomHeaders: (req, route) ->
        customHeaders = route['custom-headers'] or []
        for {key, value} in customHeaders
            req.headers[key] = value

    addAuth: (req, route, authentication) ->
        try
            updateHeader = (name, value) ->
                if value then req.headers[name] = value else delete req.headers[name]

            userInfo = JSON.stringify(authentication['user-info']) if authentication?['user-info']
            profile = JSON.stringify(req._profile) if req._profile
            userHeader = route['user-header']
            clientHeader = route['client-header']
            if clientHeader then updateHeader clientHeader, authentication?.client_id
            if userHeader then updateHeader userHeader, (user.getUserId(req))
            updateHeader 'user-info', userInfo
            updateHeader 'user-profile', profile
        catch ex
            log.error 'error adding user/client header: ' + ex + '; ' + ex.stack

    addProxyHeaders: (req) ->
      setHeaderIfMissing = (headerName, value) =>
        if not req.headers[headerName]
          req.headers[headerName] = value

      proto = if config.get('enforce-https') then 'https' else 'http'

      setHeaderIfMissing 'x-forwarded-host', req.headers.host
      setHeaderIfMissing 'x-forwarded-proto', proto
