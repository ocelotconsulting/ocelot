response = require '../response'

module.exports = (req, res, next) ->
  if(req._route.internal and not req._internal)
    response.send res, 403, 'Route is not public'
  else
    next()
