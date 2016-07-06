response = require '../response'

module.exports = (req, res, next) ->
  if(req.headers.host?)
    next()
  else
    response.send res, 404, 'Host not found'
