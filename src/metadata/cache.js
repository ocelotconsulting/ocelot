var cron = require('node-crontab'),
  http = require('http'),
  consul = require('./consul.js'),
  Promise = require('promise');

var routes, services;

function loadData() {
  loadJsonMetadata("http://stludockersbx01.monsanto.com:8500/v1/kv/routes?recurse").then(function(data) {
    routes = consul.interpretRoutes(data);
  }, function(error){console.log("could not load routes: " + error)});
  loadJsonMetadata("http://stludockersbx01.monsanto.com:8500/v1/kv/services?recurse").then(function(data) {
    services = consul.interpretServices(data);
  }, function(error){console.log("could not load services: " + error)});
}

exports.initCache = function initCron() {
  loadData();
  cron.scheduleJob('*/20 * * * * *', loadData);
};

function loadJsonMetadata(url) {
  return new Promise(function(resolve, reject) {
    http.get(url, function(res) {
      if (('' + res.statusCode).match(/^2\d\d$/)) {
        var data = '';
        res.on('data', function(chunk) {
          data += chunk;
        });
        res.on('end', function() {
          var routes = JSON.parse(data);
          resolve(routes);
        });
      } else {
        reject('error calling ' + url)
      }
    }).end();
  });
}

exports.getRoutes = function(url) {
  return routes;
};

exports.getServices = function(url) {
  return services;
};
