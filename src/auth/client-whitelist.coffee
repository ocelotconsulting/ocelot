response = require '../response'

module.exports =
  accept: (route, authentication) ->
    if authentication?.client_id and
      route['client-whitelist'] and
      route['client-whitelist'].length > 0 and
      route['client-whitelist'].indexOf(authentication.client_id) == -1
        true
    else false

  complete: (res) ->
    response.send res, 403, 'Client Unauthorized'
