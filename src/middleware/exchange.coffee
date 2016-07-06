exchange = require '../auth/exchange'

module.exports = (req, res, next) ->
  if exchange.accept req
    exchange.authCodeFlow req, res, req._route
  else
    next()
