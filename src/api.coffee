express = require 'express'
facade = require './backend/facade'
response = require './response'
Promise = require 'promise'
util = require 'util'
log = require './log'
config = require 'config'
validate = require './auth/validate'

crypto = require('crypto')
router = express.Router()

validationEnabled = config.has('api-clients')

# route fields
routeFields = ['capture-pattern', 'rewrite-pattern', 'services', 'require-auth', 'client-whitelist', 'user-header', 'client-header']
cookieFields = ['cookie-name', 'client-id', 'client-secret', 'scope', 'cookie-path', 'cookie-domain']

# host fields
hostFields = ['url']

getRoute = (key) ->
  facade.getRoutes()
  .then (data) ->
    routes = data.filter (el) ->
      el.route == key

    if routes.length == 1
      routes[0]
    else
      throw "route not found: #{key}"

sha1sum = (str) ->
    crypto.createHash('sha1').update(str).digest('hex')

validateApiUser = (req) ->
  #  todo: give back 401
  if not validationEnabled
    Promise.resolve()
  else
    validate.authentication(req)
    .then (validation) ->
      if config.get('api-clients').indexOf(validation['client_id']) == -1
        throw "invalid client id"

router.get '/routes', (req, res) ->
  validateApiUser(req, res)
  .then -> facade.getRoutes()
  .then (routes) ->
    routes.sort (a, b) => a.route.localeCompare(b.route)
    for route in routes
      route['client-secret'] = sha1sum(route['client-secret']) if route['client-secret']
    res.json routes
  .catch (err) ->
    log.error "unable to load routes: #{err}"
    response.send res, 500, 'unable to load routes'

router.get /\/routes\/(.*)/, (req, res)->
  routeKey = req.params[0]
  validateApiUser(req, res)
  .then getRoute(routeKey)
  .then (route) ->
      route['client-secret'] = sha1sum(route['client-secret']) if route['client-secret']
      res.json route
  , (err) ->
    response.send res, 404
  .catch (err) ->
    log.error "unable to get route #{route}, #{err}"
    response.send res, 500, 'unable to get route'

router.put /\/routes\/(.*)/, (req, res) ->
  routeKey = req.params[0]
  newObj = {}
  for own k,v of req.body
    if routeFields.indexOf(k) != -1 then newObj[k] = v
  if req.body[cookieFields[0]]
    for own k,v of req.body
      if cookieFields.indexOf(k) != -1 then newObj[k] = v

  validateApiUser(req, res)
  .then ->
    if req.body['client-secret']
      getRoute(routeKey).then (route) ->
        if route['client-secret'] and newObj['client-secret'] == sha1sum(route['client-secret'])
          newObj['client-secret'] = route['client-secret']
  .then -> facade.putRoute(routeKey, JSON.stringify(newObj))
  .then ->
    response.send res, 200
  .catch (err) ->
    log.error "unable to save route #{route}, #{err}"
    response.send res, 500, 'unable to save route'

router.delete /\/routes\/(.*)/, (req, res) ->
  route = req.params[0]
  validateApiUser(req, res)
  .then -> facade.deleteRoute(route)
  .then ->
    response.send res, 200
  .catch (err) ->
    log.error "unable to delete route #{route}, #{err}"
    response.send res, 500, 'unable to delete route'

router.get '/hosts/', (req, res) ->
  validateApiUser(req, res)
  .then -> facade.getHosts()
  .then (hosts) ->
    res.json hosts
  .catch (err) ->
    log.error "unable to get hosts #{err}"
    response.send res, 500, 'unable to load hosts'

router.get '/hosts/:group', (req, res)->
  group = req.params.group
  validateApiUser(req, res)
  .then -> facade.getHosts()
  .then (data) ->
    if data[group]
      res.json data[group]
    else
      response.send res, 404
  .catch (err) ->
    log.error "unable to get host #{group}, #{err}"
    response.send res, 500, 'unable to get host'

router.put '/hosts/:group/:id', (req, res) ->
  id = req.params.id
  group = req.params.group

  newObj = {}
  for own k,v of req.body
    if hostFields.indexOf(k) != -1 then newObj[k] = v

  validateApiUser(req, res)
  .then -> facade.putHost(group, id, JSON.stringify(newObj))
  .then ->
    response.send res, 200
  .catch (err) ->
    log.error "unable to save host #{id}, #{err}"
    response.send res, 500, 'unable to save host'

router.delete '/hosts/:group/:id', (req, res) ->
  id = req.params.id
  group = req.params.group
  validateApiUser(req, res)
  .then -> facade.deleteHost(group, id)
  .then -> response.send res, 200
  .catch (err) ->
    log.error "unable to delete host #{id}, #{err}"
    response.send res, 500, 'unable to delete host'

module.exports = router
