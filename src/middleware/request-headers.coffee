headers = require '../auth/headers'

module.exports = (req, res, next) ->
  headers.addAuth req
  headers.addCustomHeaders req
  headers.addProxyHeaders req
  next()
