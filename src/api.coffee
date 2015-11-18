express = require 'express'
facade = require './backend/facade'
response = require './response'
Promise = require 'promise'
util = require 'util'

router = express.Router()

router.get '/routes', (req, res) ->
  facade.getRoutes()
  .then (routes) ->
    res.json routes
  .catch (err) ->
    console.log "unable to load routes: #{err}"
    response.send res, 500, 'unable to load routes'

router.get /\/routes\/(.*)/, (req, res)->
  route = req.params[0]
  facade.getRoutes()
  .then (data) ->
    returns = data.filter (el) ->
      el.route == route
    if returns.length == 1
      res.json returns[0]
    else
      response.send res, 404
  .catch (err) ->
    console.log "unable to get route #{route}, #{err}"
    response.send res, 500, 'unable to get route'

router.put /\/routes\/(.*)/, (req, res) ->
  route = req.params[0]
#  todo: validate
  facade.putRoute(route, JSON.stringify(req.body))
  .then ->
    response.send res, 200
  .catch (err) ->
    console.log "unable to save route #{route}, #{err}"
    response.send res, 500, 'unable to save route'

router.delete /\/routes\/(.*)/, (req, res) ->
  route = req.params[0]
  facade.deleteRoute(route)
  .then ->
    response.send res, 200
  .catch (err) ->
    console.log "unable to delete route #{route}, #{err}"
    response.send res, 500, 'unable to delete route'

router.get '/hosts/', (req, res) ->
  facade.getHosts()
  .then (hosts) ->
    res.json hosts
  .catch (err) ->
    console.log "unable to get hosts #{err}"
    response.send res, 500, 'unable to load hosts'

router.get '/hosts/:group', (req, res)->
  group = req.params.group
  facade.getHosts()
  .then (data) ->
    if data[group]
      res.json data[group]
    else
      response.send res, 404
  .catch (err) ->
    console.log "unable to get host #{group}, #{err}"
    response.send res, 500, 'unable to get host'

router.put '/hosts/:group/:id', (req, res) ->
  id = req.params.id
  group = req.params.group
#  todo: validate

  facade.putHost(group, id, JSON.stringify(req.body))
  .then ->
    response.send res, 200
  .catch (err) ->
    console.log "unable to save host #{id}, #{err}"
    response.send res, 500, 'unable to save host'

router.delete '/hosts/:group/:id', (req, res) ->
  id = req.params.id
  group = req.params.group

  facade.deleteHost(group, id)
  .then ->
    response.send res, 200
  .catch (err) ->
    console.log "unable to delete host #{id}, #{err}"
    response.send res, 500, 'unable to delete host'

module.exports = router