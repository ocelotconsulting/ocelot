Url = require 'url'
_ = require 'underscore'

pickRandomEndpoint = (allEndpoints) ->
    instanceUrlStr = allEndpoints[getRandomInt(0, allEndpoints.length - 1)].url
    # url usually adds trailing slash to host, so this is not usually necessary
    if instanceUrlStr.charAt(instanceUrlStr.length - 1) != '/'
        instanceUrlStr + '/'
    else instanceUrlStr

getAllEndpoints = (route) ->
    allInstances = []
    i = 0
    while i < route.services.length
        allInstances = allInstances.concat(route.instances[route.services[i]])
        i++
    _.filter allInstances, (instance) ->
        typeof instance != 'undefined'

rewriteUrl = (urlStr, route) ->
    capture = new RegExp(route['capture-pattern'])
    match = capture.exec(urlStr)
    if capture.test(urlStr) == false
        return null
    rewritten = route['rewrite-pattern']
    i = 1
    while i <= match.length
        rewritten = rewritten.replace('$' + i, match[i])
        i++
    while rewritten.indexOf('/') == 0
        rewritten = rewritten.substring(1)
    rewritten

getRandomInt = (min, max) ->
    Math.floor(Math.random() * (max - min + 1)) + min

module.exports =
    mapRoute: (urlStr, route) ->
        rewritten = rewriteUrl(urlStr, route)
        if rewritten == null
            console.log 'capture pattern ' + route['capture-pattern'] + ' does not match: ' + urlStr
            return null
        allEndpoints = getAllEndpoints(route)
        if allEndpoints.length == 0
            return null
        instanceUrlStr = pickRandomEndpoint(allEndpoints)
        try
            return Url.parse(instanceUrlStr + rewritten)
        catch err
            console.log 'could not parse url: ' + instanceUrlStr + rewritten
            return null