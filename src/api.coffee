express = require 'express'
facade = require './backend/facade'
response = require './response'
Promise = require 'promise'

app = express()

app.get '/routes', (req, res) ->
  console.log 'getting routes'

  facade.getRoutes()
  .then (routes) ->
    res.json routes
  .catch (err) ->
    console.log err
    response.send res, 500, 'unable to load routes'

app.get '/routes/:id', (req, res)->
  id = req.params.id

  facade.getRoute(id)
  .then (data) ->
    res.json data
  .catch (err) ->
    console.log "unable to get route #{id}, #{err}"
    response.send res, 500, 'unable to get route, check the log'

app.put '/routes/:id', (req, res) ->
  id = req.params.id
  new Promise ->
    JSON.parse(req.body)
  .then (route) ->
    facade.putRoute(id, route)
  .then ->
    response.send res, 200, 'ok'
  .catch (err) ->
    console.log "unable to save route #{id}, #{err}"
    response.send res, 500, 'unable to save route, check the log'

app.delete '/routes/:id', (req, res) ->
  id = req.params.id

  facade.deleteRoute(id)
  .then ->
    response.send res, 200, 'ok'
  .catch (err) ->
    console.log "unable to delete route #{id}, #{err}"
    response.send res, 500, 'unable to delete route, check the log'

app.get '/hosts/', (req, res) ->
  facade.getServices()
  .then (hosts) ->
    res.json hosts
  .catch (err) ->
    response.send res, 500, 'unable to load hosts'

app.get '/hosts/:id', (req, res)->
  id = req.params.id

  facade.getHost(id)
  .then (data) ->
    res.json data
  .catch (err) ->
    console.log "unable to get host #{id}, #{err}"
    response.send res, 500, 'unable to get host, check the log'

app.put '/hosts/:id', (req, res) ->
  id = req.params.id
  new Promise ->
    JSON.parse(req.body)
  .then (route) ->
    facade.putHost(id, route)
  .then ->
    response.send res, 200, 'ok'
  .catch (err) ->
    console.log "unable to save host #{id}, #{err}"
    response.send res, 500, 'unable to save host, check the log'

app.delete '/hosts/:id', (req, res) ->
  id = req.params.id

  facade.deleteHost(id)
  .then ->
    response.send res, 200, 'ok'
  .catch (err) ->
    console.log "unable to delete host #{id}, #{err}"
    response.send res, 500, 'unable to delete host, check the log'

module.exports = app
