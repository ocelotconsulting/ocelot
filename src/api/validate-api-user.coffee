config = require 'config'
validationEnabled = config.has('api-clients')
validate = require '../auth/validate'

module.exports = (req, res, next) ->
    if not validationEnabled
      next()
    else
      validate.authentication(req).then (validation) ->
        if config.get('api-clients').indexOf(validation['client_id']) == -1
          res.status(403).send('Unauthorized')
        else
          next()
      , res.status(403).send('Unauthorized')
