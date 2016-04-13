log = require '../log'

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
            profile = JSON.stringify(authentication['profile']) if authentication?['profile']
            userHeader = route['user-header']
            clientHeader = route['client-header']
            if clientHeader then updateHeader clientHeader, authentication?.client_id
            if userHeader then updateHeader userHeader, (authentication?.claims?.sub?.toLowerCase() or authentication?.access_token?.user_id?.toLowerCase())
            updateHeader 'user-info', userInfo
            updateHeader 'user-profile', profile
        catch ex
            log.error 'error adding user/client header: ' + ex + '; ' + ex.stack

    addProxyHeaders: (req) ->
      addValueToHeader = (headerName, value) =>
        if not req.headers[headerName]
          req.headers[headerName] = value
        #else req.headers[headerName] = "#{req.headers[headerName]} #{value}"

      proto = if req.connection.secure then 'https' else 'http'

      addValueToHeader 'x-forwarded-host', req.headers.host
      addValueToHeader 'x-forwarded-proto', proto
      addValueToHeader 'x-forwarded-for', req.connection.remoteAddress
