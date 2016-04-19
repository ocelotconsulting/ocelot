tokenInfo = require '../auth/token-info'

module.exports = (req, res, next) ->
  if tokenInfo.accept req
      tokenInfo.complete req, res
  else
    next()
