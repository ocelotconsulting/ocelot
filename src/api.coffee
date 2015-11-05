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
    console.log err
    response.send res, 500, 'unable to load routes'

router.get '/routes/:id', (req, res)->
  id = req.params.id

  facade.getRoutes()
  .then (data) ->
    returns = data.filter (el) ->
      el.route == id
    if returns.length == 1
      res.json returns[0]
    else
      response.send res, 404
  .catch (err) ->
    console.log "unable to get route #{id}, #{err}"
    response.send res, 500, 'unable to get route, check the log'

router.put '/routes/:id', (req, res) ->
  id = req.params.id
  facade.putRoute(id, req.body)
  .then ->
    response.send res, 200, 'ok'
  .catch (err) ->
    console.log "unable to save route #{id}, #{err}"
    response.send res, 500, 'unable to save route, check the log'

router.delete '/routes/:id', (req, res) ->
  id = req.params.id

  facade.deleteRoute(id)
  .then ->
    response.send res, 200, 'ok'
  .catch (err) ->
    console.log "unable to delete route #{id}, #{err}"
    response.send res, 500, 'unable to delete route, check the log'

router.get '/hosts/', (req, res) ->
  facade.getServices()
  .then (hosts) ->
    res.json hosts
  .catch (err) ->
    response.send res, 500, 'unable to load hosts'

router.get '/hosts/:id', (req, res)->
  id = req.params.id

  facade.getServices()
  .then (data) ->
    if data[id]
      res.json data[id]
    else
      response.send res, 404
  .catch (err) ->
    console.log "unable to get host #{id}, #{err}"
    response.send res, 500, 'unable to get host, check the log'

router.put '/hosts/:id', (req, res) ->
  id = req.params.id

  facade.putHost(id, req.body)
  .then ->
    response.send res, 200, 'ok'
  .catch (err) ->
    console.log "unable to save host #{id}, #{err}"
    response.send res, 500, 'unable to save host, check the log'

router.delete '/hosts/:id', (req, res) ->
  id = req.params.id

  facade.deleteHost(id)
  .then ->
    response.send res, 200, 'ok'
  .catch (err) ->
    console.log "unable to delete host #{id}, #{err}"
    response.send res, 500, 'unable to delete host, check the log'

module.exports = router
