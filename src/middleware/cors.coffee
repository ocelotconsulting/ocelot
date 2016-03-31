cors = require '../cors'
response = require '../response'

module.exports = (req, res, next) ->
  cors.setCorsHeaders req, res
  if cors.shortCircuit req
    response.send res, 204
  else
    next()  
