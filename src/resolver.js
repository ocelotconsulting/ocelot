var http = require('http'),
    cache = require('./metadata/cache'),
    uri = require('url'),
    _ = require("underscore");

cache.initCache();

function findClosestRoute(url) {
    var path = getUrlStrStripLeadingSlash(url);
    for (pathDepth = 3; pathDepth >= 0; pathDepth--) {
        var routePath = pathDepth === 0 ? "root" : path.split('/', pathDepth).join('/');
        var foundRoute = _.find(cache.getRoutes(), function (route) {
            return route.route === routePath;
        });
        if (typeof foundRoute !== "undefined") {
            return foundRoute;
        }
    }
    console.log("no matching service found for " + url);
    return null;
}

function getUrlStrStripLeadingSlash(urlStr) {
    var path = uri.parse(urlStr).pathname;
    if (path.indexOf('/') === 0) {
        path = path.substring(1);
    }
    return path;
}

exports.resolveRoute = function (url) {
    var closestRoute = findClosestRoute(url);
    if (closestRoute != null) {
        closestRoute['instances'] = {};
        _.each(closestRoute.services, function (service) {
            closestRoute['instances'][service] = cache.getServices()[service];
        });
    }
    return closestRoute;
};
