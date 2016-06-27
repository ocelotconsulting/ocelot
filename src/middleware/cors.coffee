cors = require '../cors'
response = require '../response'

module.exports = (req, res, next) ->
  cors.setCorsHeaders req, res
  if cors.isPreflightRequest req
    response.send res, 204
  else if cors.isOriginUntrusted req
    response.send res, 403, "Origin #{req.headers.origin} forbidden"
  else
    next()
