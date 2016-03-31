refresh = require '../auth/refresh/token-refresh'

module.exports = (req, res, next) ->
  if refresh.accept req, req._route, req.cookies
    refresh.complete req, res, req._route, req.cookies
  else
    next()
