var Url = require('url'),
    _ = require('underscore');

exports.mapRoute = function (urlStr, route) {
    var capture = new RegExp(route['capture-pattern']);
    var rewrite = route['rewrite-pattern'];

    var match = capture.exec(urlStr);
    var rewritten = rewrite;

    if (capture.test(urlStr) === false) {
        console.log("capture pattern " + route['capture-pattern'] + " does not match: " + urlStr);
        return null;
    }

    for (i = 1; i <= match.length; i++) {
        rewritten = rewritten.replace('$' + i, match[i]);
    }

    while (rewritten.indexOf('/') === 0) {
        rewritten = rewritten.substring(1);
    }

    var allInstances = [];
    for (i = 0; i < route.services.length; i++) {
        allInstances = allInstances.concat(route.instances[route.services[i]]);
    }
    allInstances = _.filter(allInstances, function(instance){return typeof instance !== 'undefined';});

    if (allInstances.length === 0) {
        return null;
    }

    // url usually adds trailing slash to host, so this is not usually necessary
    var instanceUrlStr = allInstances[getRandomInt(0, allInstances.length - 1)].url;
    if (instanceUrlStr.indexOf("/" !== instanceUrlStr.length - 1)) {
        instanceUrlStr = instanceUrlStr + "/";
    }

    return Url.parse(instanceUrlStr + rewritten);
};

function getRandomInt(min, max) {
    return Math.floor(Math.random() * (max - min + 1)) + min;
}