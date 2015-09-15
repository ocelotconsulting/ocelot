var Url = require('url'),
    _ = require('underscore');

exports.mapRoute = function (urlStr, route) {
    var rewritten = rewriteUrl(urlStr, route);
    if(rewritten === null){
        console.log("capture pattern " + route['capture-pattern'] + " does not match: " + urlStr);
        return null;
    }

    var allEndpoints = getAllEndpoints(route);
    if (allEndpoints.length === 0) {
        return null;
    }

    var instanceUrlStr = pickRandomEndpoint(allEndpoints);

    try{
        return Url.parse(instanceUrlStr + rewritten);
    }
    catch(err){
        console.log('could not parse url: ' + instanceUrlStr + rewritten)
        return null;
    }
};

function pickRandomEndpoint(allEndpoints){
    var instanceUrlStr = allEndpoints[getRandomInt(0, allEndpoints.length - 1)].url;
    // url usually adds trailing slash to host, so this is not usually necessary
    if (instanceUrlStr.indexOf("/" !== instanceUrlStr.length - 1)) {
        instanceUrlStr = instanceUrlStr + "/";
    }
    return instanceUrlStr;
}

function getAllEndpoints(route){
    var allInstances = [];
    for (i = 0; i < route.services.length; i++) {
        allInstances = allInstances.concat(route.instances[route.services[i]]);
    }
    return _.filter(allInstances, function(instance){return typeof instance !== 'undefined';});
}

function rewriteUrl(urlStr, route){
    var capture = new RegExp(route['capture-pattern']);
    var match = capture.exec(urlStr);

    if (capture.test(urlStr) === false) {
        return null;
    }

    var rewritten = route['rewrite-pattern'];

    for (i = 1; i <= match.length; i++) {
        rewritten = rewritten.replace('$' + i, match[i]);
    }

    while (rewritten.indexOf('/') === 0) {
        rewritten = rewritten.substring(1);
    }

    return rewritten;
}

function getRandomInt(min, max) {
    return Math.floor(Math.random() * (max - min + 1)) + min;
}