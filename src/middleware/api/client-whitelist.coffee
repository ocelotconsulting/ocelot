config = require 'config'
validationEnabled = config.has('api-clients')
log = require '../../log'

module.exports = (req, res, next) ->
  if req._auth
    clientId = req._auth.client_id
    if config.get('api-clients').indexOf(clientId) == -1
      log.debug "client #{clientId} is unauthorized"
      res.status(403).send('API Client Unauthorized')
    else
      next()
  else
    next()
