config = require 'config'
objectPath = require 'object-path'

userPath = config.get 'authentication.user-path'
clientPath = config.get 'authentication.client-path'

module.exports =
  getUserId: (req) ->
    getAuthUser = () ->
      objectPath.get req?._auth, userPath

    getUserHeader = () ->
      if req._route
        route = req._route
        client_id = objectPath.get req?._auth, clientPath
        allowElevatedTrust = client_id and
          route['user-header'] and
          (route['elevated-trust'] == true or (typeof route['elevated-trust']?.includes == 'function' and route['elevated-trust'].includes(client_id))) and
          typeof route['client-whitelist']?.includes == 'function' and route['client-whitelist'].includes(client_id)
        req.headers[route['user-header']] if allowElevatedTrust

    (getAuthUser() or getUserHeader())?.toLowerCase()

  getClientId: (req) ->
    objectPath.get req?._auth, clientPath
