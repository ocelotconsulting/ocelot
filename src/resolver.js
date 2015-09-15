var http = require('http'),
    cache = require('./backend/cache'),
    uri = require('url'),
    _ = require("underscore");

cache.initCache();

exports.resolveRoute = function (url, host) {
    var closestRoute = findRouteByHost(host) || findRouteByPath(url);
    if (closestRoute != null) {
        closestRoute.instances = {};
        _.each(closestRoute.services, function (service) {
            closestRoute.instances[service] = cache.getServices()[service];
        });
    }
    return closestRoute;
};

function findRouteByHost(host){
    if(host.indexOf(".") > 0){
        var subdomain = host.split(".")[0];
        var route = findRoute(subdomain);
        if (typeof route !== "undefined") {
            return route;
        }
    }
    return null;
}

function findRouteByPath(url) {
    var path = getUrlStrStripLeadingSlash(url);
    for (pathDepth = 3; pathDepth >= 0; pathDepth--) {
        var routePath = pathDepth === 0 ? "root" : path.split('/', pathDepth).join('/');
        var route = findRoute(routePath);
        if (typeof route !== "undefined") {
            return route;
        }
    }
    return null;
}

function findRoute(key){
    return _.find(cache.getRoutes(), function (route) {
        return route.route === key;
    });
}

function getUrlStrStripLeadingSlash(urlStr) {
    var path = uri.parse(urlStr).pathname;
    if (path.indexOf('/') === 0) {
        path = path.substring(1);
    }
    return path;
}
