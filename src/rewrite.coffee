Url = require 'url'
_ = require 'underscore'

pickRandomEndpoint = (allEndpoints) ->
    instanceUrlStr = allEndpoints[getRandomInt(0, allEndpoints.length - 1)].url
    if instanceUrlStr.charAt(instanceUrlStr.length - 1) != '/'
        instanceUrlStr + '/'
    else instanceUrlStr

getAllEndpoints = (route) ->
    allInstances = []
    i = 0
    allInstances = allInstances.concat(route.instances[route.services[i]]) for i in [0 .. route.services.length]
    _.filter allInstances, (instance) ->
        typeof instance != 'undefined'

rewriteUrl = (targetHost, incomingPath, route) ->
    capture = new RegExp(route['capture-pattern'])
    rewrittenPath = route['rewrite-pattern']

    if capture.test(incomingPath)
        match = capture.exec(incomingPath)
        rewrittenPath = rewrittenPath.replace('$' + i, match[i]) for i in [1 ... match.length]
        targetHost = targetHost.replace('$' + i, match[i]) for i in [1 ... match.length]

    while rewrittenPath.indexOf('/') == 0
        rewrittenPath = rewrittenPath.substring(1)

    return targetHost + rewrittenPath

getRandomInt = (min, max) ->
    Math.floor(Math.random() * (max - min + 1)) + min

module.exports =
    mapRoute: (incomingPath, route) ->
        allEndpoints = getAllEndpoints(route)
        if allEndpoints.length == 0
            return null

        targetHost = pickRandomEndpoint(allEndpoints)
        rewritten = rewriteUrl(targetHost, incomingPath, route)

        try
            Url.parse(rewritten)
        catch err
            console.log 'could not parse url: ' + instanceUrlStr + rewritten
            return null