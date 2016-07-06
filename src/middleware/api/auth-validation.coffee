config = require 'config'
validationEnabled = config.has('api-clients')
validateAuthentication = require '../validate-authentication'

module.exports = (req, res, next) ->
  if not validationEnabled
    next()
  else
    validateAuthentication req, res, next
