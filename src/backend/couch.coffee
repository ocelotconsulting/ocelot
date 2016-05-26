config = require '../config'
cron = require 'node-crontab'
hosts = {}
log = require '../log'
routes = []
url = null
superagent = require('superagent')
agent = require('superagent-promise')(superagent, Promise)

reload = ->
    getRoutes()
    .then (stuff) ->
        routes = stuff
    .catch (err) ->
        log.error "unable to load routes: #{err}"

    getHosts()
    .then (stuff) ->
        hosts = stuff
    .catch (err) ->
        log.error "unable to load hosts: #{err}"

getRoutes = ->
  agent.get "#{url}/routes/_design/routes/_view/all?include_docs=true"
  .set 'Accept', 'application/json'
  .addBasicAuthHeader()
  .then (res) ->
    res.body.rows.map (row) ->
      doc = row.doc
      doc.route = doc._id
      doc

getHosts = ->
  agent.get "#{url}/services/_design/services/_view/all?group=true"
  .set 'Accept', 'application/json'
  .addBasicAuthHeader()
  .then (res) ->
    hosts = {}
    res.body.rows.forEach (row) ->
      hosts[row.key] = row.value
    hosts

module.exports =
  detect: ->
    config.get('backend.provider') is "couch"

  init: ->
    url = config.get('backend.url')
    authHeader = null

    if config.get('backend.user')
      userpass = "#{config.get('backend.user')}:#{config.get('backend.password')}"
      authHeader = "Basic " + new Buffer(userpass).toString('base64')

    superagent.Request.prototype.addBasicAuthHeader = () ->
      if authHeader then this.set "Authorization", authHeader else this

    reload()
    cron.scheduleJob '*/30 * * * * *', reload

  getCachedRoutes: -> routes
  getRoutes: () -> getRoutes()
  putRoute: (id, route) ->
    agent.put "#{url}/routes/#{encodeURIComponent(id)}", route
  deleteRoute: (id) ->
    agent.del "#{url}/routes/#{encodeURIComponent(id)}"

  getCachedHosts: () -> hosts
  getHosts: () -> getHosts()
  putHost: (group, id, host) ->
    agent.put "#{url}/services/#{encodeURIComponent(id)}", host
  deleteHost: (group, id) ->
    agent.del "#{url}/services/#{encodeURIComponent(id)}"
