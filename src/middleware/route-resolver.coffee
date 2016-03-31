resolver = require '../resolver'
response = require '../response'

redirectOrSend404 = (req, res, host) ->
    if host.indexOf('www.') is 0
        res.setHeader 'Location', "#{config.get('default-protocol')}://#{host.slice 4}#{req.url}"
        response.send res, 301
    else
        response.send res, 404, 'Route not found'

module.exports = (req, res, next) ->
  {host} = req.headers
  route = resolver.resolveRoute req.url, host
  if not route?
    redirectOrSend404 req, res, host
  else
    req._route = route
    next()
