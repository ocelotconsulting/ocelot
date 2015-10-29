redis = require 'redis'
config = require 'config'
cron = require 'node-crontab'
{client, routes, hosts} = {}

reloadData = ->
  client.hgetall "routes", (err, obj) ->

    if err or not obj
      console.log "error loading data from redis: error: #{err}, obj: #{JSON.stringify(obj)} "
    else
      res = []

      for k,v of obj
        try
          json = JSON.parse(v)
          json.route = k
          res.push json
        catch e
          console.log 'error parsing: ' + k

      routes = res


  client.hgetall "hosts", (err, obj) ->
    if err or not obj
      console.log "error loading data from redis: error: #{err}, obj: #{JSON.stringify(obj)} "
    else
      res = {}

      for k,v of obj
        try
          json = JSON.parse(v)
          json.id = k
          if not res[json.name]?
            res[json.name] = []
          res[json.name].push json
        catch e
          console.log 'error parsing: ' + k

      hosts = res

module.exports =
  initCache: ->
    if not config.has('backend.redis.host') or not config.has('backend.redis.port')
      throw 'redis backend mis-configured'

    client = redis.createClient
      host: config.get 'backend.redis.host'
      port: config.get 'backend.redis.port'

    client.on "error", (err) ->
      console.log "Redis client error: #{err}"

    reloadData()
    cron.scheduleJob '*/30 * * * * *', reloadData
  getRoutes: ->
    routes
  getServices: ->
    hosts
  reloadData: reloadData