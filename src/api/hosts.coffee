express = require 'express'
router = express.Router()
facade = require '../backend/facade'
response = require '../response'
log = require '../log'
config = require 'config'
context = require '../auth/context'

# host fields
hostFields = ['url', 'user-id', '_rev']

router.get '/', (req, res) ->
  facade.getHosts()
  .then (hosts) ->
    res.json hosts
  .catch (err) ->
    log.error "unable to get hosts #{err}"
    response.send res, 500, 'unable to load hosts'

router.get '/:group', (req, res)->
  group = req.params.group
  facade.getHosts()
  .then (data) ->
    if data[group]
      res.json data[group]
    else
      response.send res, 404
  .catch (err) ->
    log.error "unable to get host #{group}, #{err}"
    response.send res, 500, 'unable to get host'

router.put '/:group/:id', (req, res) ->
  id = req.params.id
  group = req.params.group

  newObj = {}
  for own k,v of req.body
    if hostFields.indexOf(k) != -1 then newObj[k] = v

  newObj['user-id'] = context.getUserId(req) or 'unknown'

  facade.putHost(group, id, JSON.stringify(newObj))
  .then ->
    response.send res, 200
  .catch (err) ->
    log.error "unable to save host #{id}, #{err}"
    response.send res, 500, 'unable to save host'

router.delete '/:group/:id', (req, res) ->
  id = req.params.id
  group = req.params.group
  facade.deleteHost(group, id)
  .then -> response.send res, 200
  .catch (err) ->
    log.error "unable to delete host #{id}, #{err}"
    response.send res, 500, 'unable to delete host'

module.exports = router
