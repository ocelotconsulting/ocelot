express = require 'express'
facade = require './backend/facade'
response = require './response'
Promise = require 'promise'
util = require 'util'
log = require './log'
config = require 'config'

router = express.Router()

apiUserPass = "#{config.get('api.user')}:#{config.get('api.password')}"
validationEnabled = config.has('api.user')

validateApiUser ->
  passAuth ->
    authHeader = req.headers.authorization
    authHeader?.slice(0, 6).toLowerCase() == "basic " and
      new Buffer(authHeader.slice 6, 'base64').toString('utf8') == apiUserPass

  if not validationEnabled or passAuth
    Promise.resolve()
  else
    Promise.reject()

router.get '/routes', (req, res) ->
  validateApiUser()
  .then -> facade.getRoutes()
  .then (routes) -> res.json routes
  .catch (err) ->
    log.error "unable to load routes: #{err}"
    response.send res, 500, 'unable to load routes'

router.get /\/routes\/(.*)/, (req, res)->
  route = req.params[0]

  validateApiUser()
  .then -> facade.getRoutes()
  .then (data) ->
    returns = data.filter (el) ->
      el.route == route
    if returns.length == 1
      res.json returns[0]
    else
      response.send res, 404
  .catch (err) ->
    log.error "unable to get route #{route}, #{err}"
    response.send res, 500, 'unable to get route'

router.put /\/routes\/(.*)/, (req, res) ->
  route = req.params[0]
#  todo: validate
  validateApiUser()
  .then -> facade.putRoute(route, JSON.stringify(req.body))
  .then ->
    response.send res, 200
  .catch (err) ->
    log.error "unable to save route #{route}, #{err}"
    response.send res, 500, 'unable to save route'

router.delete /\/routes\/(.*)/, (req, res) ->
  route = req.params[0]
  validateApiUser()
  .then -> facade.deleteRoute(route)
  .then ->
    response.send res, 200
  .catch (err) ->
    log.error "unable to delete route #{route}, #{err}"
    response.send res, 500, 'unable to delete route'

router.get '/hosts/', (req, res) ->
  validateApiUser()
  .then -> facade.getHosts()
  .then (hosts) ->
    res.json hosts
  .catch (err) ->
    log.error "unable to get hosts #{err}"
    response.send res, 500, 'unable to load hosts'

router.get '/hosts/:group', (req, res)->
  group = req.params.group
  validateApiUser()
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
#  todo: validate

  validateApiUser()
  .then -> facade.putHost(group, id, JSON.stringify(req.body))
  .then ->
    response.send res, 200
  .catch (err) ->
    log.error "unable to save host #{id}, #{err}"
    response.send res, 500, 'unable to save host'

router.delete '/hosts/:group/:id', (req, res) ->
  id = req.params.id
  group = req.params.group

  validateApiUser()
  .then -> facade.deleteHost(group, id)
  .then -> response.send res, 200
  .catch (err) ->
    log.error "unable to delete host #{id}, #{err}"
    response.send res, 500, 'unable to delete host'

module.exports = router