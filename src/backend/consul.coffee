cron = require 'node-crontab'
_ = require 'underscore'
config = require 'config'
{routes, hosts, routeUrl, hostUrl} = {}
routeRegex = /[^/]+[/](.+)/
servicesRegex = /[^/]+[/](.+)\/(.+)/
Promise = this.Promise || require 'promise'
agent = require('superagent-promise')(require('superagent'), Promise)

getRoutes = ->
    agent.get(routeUrl + '/?recurse')
    .then (data) ->
        JSON.parse(data.text)
    .then (json)->
        parseRoutes(json)

getHosts = ->
    agent.get(hostUrl + '/?recurse')
    .then (data) ->
        JSON.parse(data.text)
    .then (json)->
        parseHosts(json)

reload = ->
    getRoutes()
    .then (stuff) ->
        routes = stuff
    .catch (err) ->
        console.log "unable to load routes: #{err}"

    getHosts()
    .then (stuff) ->
        hosts = stuff
    .catch (err) ->
        console.log "unable to load hosts: #{err}"

parseConsul = (consulJson, keyRegex, mutate) ->
    _(consulJson).chain().map((item) ->
        try
            if keyRegex.test item.Key
                decodedValue = JSON.parse(new Buffer(item.Value, 'base64').toString('utf8'))
                match = keyRegex.exec item.Key
                mutate decodedValue, match
        catch e
            console.log 'error parsing: ' + item.Key
    ).compact().value()


parseRoutes = (consulJson) ->
    parseConsul consulJson, routeRegex, (value, match) ->
        value.route = match[1]
        value

parseHosts = (consulJson) ->
    hosts = _(parseConsul consulJson, servicesRegex, (value, match) ->
        value.name = match[1]
        value.id = match[2]
        value
    ).groupBy 'name'
    for own k,v of hosts
        for i in v
            i.name = undefined
    hosts

module.exports =
    detect: ->
        config.has('backend.consul.routes') and config.has('backend.consul.hosts')

    init: ->
        routeUrl = config.get 'backend.consul.routes'
        hostUrl = config.get 'backend.consul.hosts'
        reload()
        cron.scheduleJob '*/30 * * * * *', reload

    reloadData: reload

    getCachedRoutes: ->
        routes
    getRoutes: ->
        getRoutes()
    putRoute: (key, route) ->
        agent.put("#{routeUrl}/#{key}", route)
    deleteRoute: (key) ->
        agent.del("#{routeUrl}/#{key}")

    getCachedHosts: ->
        hosts
    getHosts: ->
        getHosts()
    putHost: (group, id, host) ->
        agent.put("#{hostUrl}/#{group}/#{id}", host)
    deleteHost: (group, id) ->
        agent.del("#{hostUrl}/#{group}/#{id}")
