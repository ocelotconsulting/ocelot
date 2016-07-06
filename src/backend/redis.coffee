redis = require 'redis'
config = require 'config'
cron = require 'node-crontab'
{client, routes, hosts} = {}
hostRegex = /(.+)\/(.+)/
log = require '../log'

getRoutes = () ->
  new Promise (accept, reject) ->
    client.hgetall "routes", (err, obj) ->
      if err
        reject(err)
      else
        res = []
        for own k,v of obj
          try
            json = JSON.parse(v)
            json.route = k
            res.push json
          catch e
            log.warning "issue found parsing routes entry as json '#{k}'='#{v}' #{e}"
        accept res

getHosts = () ->
  new Promise (accept, reject) ->
    client.hgetall "hosts", (err, obj) ->
      if err
        reject err
      else
        res = {}
        for own k,v of obj
          try
            json = JSON.parse(v)
            if hostRegex.test k
              match = hostRegex.exec k
              name = match[1]
              json.id = match[2]
              if not res[name]?
                res[name] = []
                res[name].push json
          catch e
            log.warning "issue found parsing host entry as json '#{k}'='#{v}' #{e}"
        accept res

reloadData = ->
  getRoutes()
  .then (res) ->
    routes = res
  .catch (err) ->
    log.error("error loading routes: #{err}")

  getHosts()
  .then (res) ->
    hosts = res
  .catch (err) ->
    log.error("error loading hosts #{err}")

init = ->
  host = config.get 'backend.host'
  port = config.get 'backend.port'
  client = redis.createClient
    host: host
    port: port

  client.on "error", (err) ->
    log.error "Redis client error: #{err}"

  reloadData()
  cron.scheduleJob '*/30 * * * * *', reloadData

module.exports =
  detect: ->
    config.has('backend.provider') and config.get('backend.provider') == "redis"

  init: -> init()

  getCachedRoutes: -> routes
  getRoutes: -> getRoutes()

  putRoute: (id, route) ->
    new Promise (resolve, reject) ->
      client.hset "routes", id, route, (err) ->
        if(err?)
          reject "could not put route #{id}: #{err}"
        else
          resolve()

  deleteRoute: (id) ->
    new Promise (resolve, reject) ->
      client.hdel "routes", id, (err) ->
        if(err?)
          reject "could not delete route #{id}: #{err}"
        else
          resolve()

  getCachedHosts: -> hosts
  getHosts: -> getHosts()

  putHost: (group, id, host) ->
    new Promise (resolve, reject) ->
      client.hset "hosts", "#{group}/#{id}", host, (err) ->
        if(err?)
          reject "could not put host #{id}: #{err}"
        else
          resolve()

  deleteHost: (group, id) ->
    new Promise (resolve, reject) ->
      client.hdel "hosts", "#{group}/#{id}", (err) ->
        if(err?)
          reject "could not delete host #{id}: #{err}"
        else
          resolve()
