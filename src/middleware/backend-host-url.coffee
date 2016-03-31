rewrite = require '../rewrite'
response = require '../response'

module.exports = (req, res, next) ->
  url = rewrite.mapRoute req.url, req._route
  if not url
    response.send res, 404, 'No active URL for route'
  else
    req._url = url
    next()
