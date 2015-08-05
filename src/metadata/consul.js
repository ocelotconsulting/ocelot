var cron = require('node-crontab'),
    jsonLoader = require('./json'),
    _ = require("underscore"),
    config = require('config');

var routes, services, routeUrl, serviceUrl;
var routeRegex =  /[^/]+[/](.+)/;
var servicesRegex = /[^/]+[/](.+)\/(.+)/;

function loadData() {
    jsonLoader.get(routeUrl).then(function (data) {
        routes = parseRoutes(data);
    }, function (error) {
        console.log("could not load routes: " + error)
    });
    jsonLoader.get(serviceUrl).then(function (data) {
        services = parseServices(data);
    }, function (error) {
        console.log("could not load services: " + error)
    });
}

parseConsul = function (consulJson, keyRegex, mutate) {
    return _.filter(_.map(consulJson, function (item) {
        try {
            if (keyRegex.test(item.Key)) {
                var decodedValue = JSON.parse(new Buffer(item.Value, 'base64').toString('utf8'));
                    var match = keyRegex.exec(item.Key);
                return mutate(decodedValue, match);
            }
            else {
                return null;
            }
        } catch (e) {
            console.log('error parsing: ' + item.Key);
            return null;
        }

    }), function (obj) {
        return obj !== null;
    });
};

parseRoutes = function (consulJson) {
    return parseConsul(consulJson, routeRegex, function (value, match) {
        value.route = match[1];
        return value;
    });
};

parseServices = function (consulJson) {
    return _.groupBy(parseConsul(consulJson, servicesRegex, function (value, match) {
        value.name = match[1];
        value.id = match[2];
        return value;
    }), 'name');
};

exports.initCache = function initCron() {
    if (!config.has("backend.consul.routes") || !config.has("backend.consul.services")) {
        throw("consul backend mis-configured");
    }
    routeUrl = config.get("backend.consul.routes");
    serviceUrl = config.get("backend.consul.services");

    loadData();
    cron.scheduleJob('*/20 * * * * *', loadData);
};

exports.getRoutes = function () {
    return routes;
};

exports.getServices = function () {
    return services;
};
