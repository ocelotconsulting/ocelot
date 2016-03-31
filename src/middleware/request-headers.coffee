headers = require '../auth/headers'

module.exports = (req, res, next) ->
  headers.addAuth req, req._route, req._auth, req.cookies
  headers.addCustomHeaders req, req._route
  next()
