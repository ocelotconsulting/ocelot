log = require '../log'
config = require 'config'
context = require './context'

module.exports =
  addCustomHeaders: (req) ->
    route = req._route
    customHeaders = route['custom-headers'] or []
    for {key, value} in customHeaders
      req.headers[key] = value

  addAuth: (req) ->
    route = req._route
    authentication = req._auth
    try
      updateHeader = (name, value) ->
        if value then req.headers[name] = value else delete req.headers[name]

      profile = JSON.stringify(req._profile) if req._profile
      userHeader = route['user-header']
      clientHeader = route['client-header']
      if clientHeader then updateHeader clientHeader, context.getClientId(req)
      if userHeader then updateHeader userHeader, (context.getUserId(req))
      updateHeader 'user-profile', profile
    catch ex
      log.error 'error adding user/client header: ' + ex + '; ' + ex.stack

  addProxyHeaders: (req) ->
    setHeaderIfMissing = (headerName, value) ->
      if not req.headers[headerName]
        req.headers[headerName] = value

    proto = if config.get('enforce-https') then 'https' else 'http'
    setHeaderIfMissing 'x-forwarded-host', req.headers.host
    setHeaderIfMissing 'x-forwarded-proto', proto
