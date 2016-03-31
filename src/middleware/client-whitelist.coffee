clientWhitelist = require '../auth/client-whitelist'

module.exports = (req, res, next) ->
  if clientWhitelist.accept req._route, req._auth
    clientWhitelist.complete res
  else
    next()
