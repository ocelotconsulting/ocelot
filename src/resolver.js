var http = require('http'),
  httpProxy = require('http-proxy'),
  cache = require('./metadata/cache.js'),
  uri = require('url'),
  _ = require("underscore");

cache.initCache();

function findClosestRoute(url) {
  path = uri.parse(url).pathname;
  if (path.indexOf('/') === 0) {
    path = path.substring(1);
  }
  for (pathDepth = 3; pathDepth > 0; pathDepth--) {
    var routePath = path.split('/', pathDepth).join('/');
    var foundRoute = _.find(cache.getRoutes(), function(route) {
      return route.route === routePath;
    });
    if (typeof foundRoute !== "undefined") {
      return foundRoute;
    }
  }
  console.log("no matching service found for " + url);
  return null;
}

exports.resolveRoute = function(url) {
  var closestRoute = findClosestRoute(url);
  if (closestRoute != null) {
    closestRoute['instances'] = {};
    _.each(closestRoute.services, function(service) {
      closestRoute['instances'][service] = cache.getServices()[service];
    });
  }
  return closestRoute;
}
