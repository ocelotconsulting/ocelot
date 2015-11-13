express = require 'express'
facade = require './backend/facade'
response = require './response'
Promise = require 'promise'
util = require 'util'

router = express.Router()

router.get '/routes', (req, res) ->
  Promise.resolve facade.getRoutes()
  .then (routes) ->
    res.json routes
  .catch (err) ->
    console.log "unable to load routes: #{err}"
    response.send res, 500, 'unable to load routes'

router.get '/routes/:id', (req, res)->
  id = req.params.id
  Promise.resolve facade.getRoutes()
  .then (data) ->
    returns = data.filter (el) ->
      el.route == id
    if returns.length == 1
      res.json returns[0]
    else
      response.send res, 404
  .catch (err) ->
    console.log "unable to get route #{id}, #{err}"
    response.send res, 500, 'unable to get route'

router.put '/routes/:id/', (req, res) ->
  id = req.params.id
  console.log "> #{JSON.stringify(req.body)}"

  facade.putRoute(id, JSON.stringify(req.body))
  .then ->
    response.send res, 200
  .catch (err) ->
    console.log "unable to save route #{id}, #{err}"
    response.send res, 500, 'unable to save route'

router.delete '/routes/:id', (req, res) ->
  id = req.params.id
  facade.deleteRoute(id)
  .then ->
    response.send res, 200
  .catch (err) ->
    console.log "unable to delete route #{id}, #{err}"
    response.send res, 500, 'unable to delete route'

router.get '/hosts/', (req, res) ->
  Promise.resolve facade.getHosts()
  .then (hosts) ->
    res.json hosts
  .catch (err) ->
    console.log "unable to get hosts #{err}"
    response.send res, 500, 'unable to load hosts'

router.get '/hosts/:group', (req, res)->
  group = req.params.group
  Promise.resolve facade.getHosts()
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
  req.body.id = id
  req.body.name = group

  facade.putHost("#{group}/#{id}", JSON.stringify(req.body))
  .then ->
    response.send res, 200
  .catch (err) ->
    console.log "unable to save host #{id}, #{err}"
    response.send res, 500, 'unable to save host'

router.delete '/hosts/:group/:id', (req, res) ->
  id = req.params.id
  group = req.params.group

  facade.deleteHost("#{group}/#{id}")
  .then ->
    response.send res, 200
  .catch (err) ->
    console.log "unable to delete host #{id}, #{err}"
    response.send res, 500, 'unable to delete host'

module.exports = router