tokenInfo = require '../auth/token-info'

module.exports = (req, res, next) ->
  if tokenInfo.accept req
      tokenInfo.complete req._route, res, req._auth
  else
    next()
