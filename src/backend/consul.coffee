cron = require 'node-crontab'
_ = require 'underscore'
config = require 'config'
{routes, services, routeUrl, serviceUrl} = {}
routeRegex = /[^/]+[/](.+)/
servicesRegex = /[^/]+[/](.+)\/(.+)/
Promise = this.Promise || require('promise');
agent = require('superagent-promise')(require('superagent'), Promise);

reload = ->
    agent.get(routeUrl + '/?recurse')
    .then (data) ->
        JSON.parse(data.text)
    .then (json)->
        routes = parseRoutes(json)
    .catch (err) ->
        console.log 'could not load routes: ' + err

    agent.get(serviceUrl + '/?recurse')
    .then (data) ->
        JSON.parse(data.text)
    .then (json)->
        services = parseServices(json)
    .catch (err) ->
        console.log 'could not load services: ' + err

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

parseServices = (consulJson) ->
    _(parseConsul consulJson, servicesRegex, (value, match) ->
        value.name = match[1]
        value.id = match[2]
        value
    ).groupBy 'name'

module.exports =
    init: ->
        if not config.has('backend.consul.routes') or not config.has('backend.consul.services')
            throw 'consul backend mis-configured'
        routeUrl = config.get 'backend.consul.routes'
        serviceUrl = config.get 'backend.consul.services'
        reload()
        cron.scheduleJob '*/30 * * * * *', reload

    reloadData: reload

    getRoutes: ->
        Promise.resolve routes
    getRoute: (id) ->
        returns = routes.filter (el) ->
            el.route == id
        Promise.resolve returns
    putRoute: (id, route) ->
        agent.put("#{routeUrl}/#{id}", route)
    deleteRoute: (id) ->
        agent.delete("#{routeUrl}/#{id}")

    getServices: ->
        Promise.resolve services
    getHost: (id) ->
        Promise.resolve services[id]
    putHost: (id, host) ->
        agent.put("#{serviceUrl}/#{id}", host)
    deleteHost: (id) ->
        agent.delete("#{serviceUrl}/#{id}")
