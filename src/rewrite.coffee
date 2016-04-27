url = require 'url'
_ = require 'underscore'
log = require './log'

pickRandomEndpoint = (allEndpoints) ->
    instanceUrlStr = allEndpoints[getRandomInt 0, allEndpoints.length - 1]
    instanceUrlStr + (if instanceUrlStr.charAt(instanceUrlStr.length - 1) is '/' then '' else '/')

rewriteUrl = (targetHost, incomingPath, route) ->
    capture = new RegExp(route['capture-pattern'] or '(.*)')
    rewrittenPath = route['rewrite-pattern'] or '$1'

    if capture.test(incomingPath)
        match = capture.exec(incomingPath)
        rewrittenPath = rewrittenPath.replace('$' + i, match[i]) for i in [1 ... match.length]
        targetHost = targetHost.replace('$' + i, match[i]) for i in [1 ... match.length]

    while rewrittenPath.indexOf('/') == 0
        rewrittenPath = rewrittenPath.substring(1)

    targetHost + rewrittenPath

getAllEndpoints = (route) ->
    hosts = route.hosts or []
    serviceHosts = route.services or []
    serviceHosts.reduce (prev, serviceName) ->
        prev.concat route.instances[serviceName].map (service) ->
          service.url
      , hosts

getRandomInt = (min, max) ->
    Math.floor(Math.random() * (max - min + 1)) + min

module.exports =
    mapRoute: (incomingPath, route) ->
        allEndpoints = getAllEndpoints route
        if allEndpoints.length > 0
            targetHost = pickRandomEndpoint allEndpoints
            rewritten = rewriteUrl targetHost, incomingPath, route
        try
            url.parse rewritten
        catch err
            log.error "could not parse url: #{rewritten}"
