cron = require 'node-crontab'
jsonLoader = require './json'
_ = require 'underscore'
config = require 'config'
{routes, services, routeUrl, serviceUrl} = {}
routeRegex = /[^/]+[/](.+)/
servicesRegex = /[^/]+[/](.+)\/(.+)/

reloadData = ->
    jsonLoader.get(routeUrl).then ((data) ->
        routes = parseRoutes(data)
    ), (error) ->
        console.log 'could not load routes: ' + error
    jsonLoader.get(serviceUrl).then ((data) ->
        services = parseServices(data)
    ), (error) ->
        console.log 'could not load services: ' + error

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
    initCache: ->
        if not config.has('backend.consul.routes') or not config.has('backend.consul.services')
            throw 'consul backend mis-configured'
        routeUrl = config.get 'backend.consul.routes'
        serviceUrl = config.get 'backend.consul.services'
        reloadData()
        cron.scheduleJob '*/30 * * * * *', reloadData
    getRoutes: ->
        routes
    getServices: ->
        services
    reloadData: reloadData