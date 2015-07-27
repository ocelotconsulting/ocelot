var Url = require('url');

exports.mapRoute = function (url, route) {
    var capture = new RegExp(route['capture-pattern']);
    var rewrite = route['rewrite-pattern'];
    var match = capture.exec(url);
    var rewritten = rewrite;

    if (capture.test(url) === false) {
        console.log("capture pattern " + route['capture-pattern'] + " does not match: " + url);
        return null;
    }

    for (i = 1; i <= match.length; i++) {
        rewritten = rewritten.replace('$' + i, match[i]);
    }
    if (rewritten.indexOf('/') === 0) {
        rewritten = rewritten.substring(1);
    }

    var allInstances = [];
    for (i = 0; i < route.services.length; i++) {
        allInstances = allInstances.concat(route.instances[route.services[i]]);
    }

    if (allInstances.length === 0) {
        return null;
    }

    var instance = allInstances[getRandomInt(0, allInstances.length - 1)];
    return Url.parse(instance.url + rewritten);
};

function getRandomInt(min, max) {
    return Math.floor(Math.random() * (max - min + 1)) + min;
}
