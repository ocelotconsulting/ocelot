response = require '../response'
context = require '../auth/context'

accept = (req) ->
  authentication = req._auth
  route = req._route

  if context.getClientId(req) and
    route['client-whitelist'] and
    route['client-whitelist'].length > 0 and
    route['client-whitelist'].indexOf(context.getClientId(req)) == -1
      true
  else false

complete = (res) ->
  response.send res, 403, 'Client Unauthorized'

module.exports = (req, res, next) ->
  if accept req
    complete res
  else
    next()
