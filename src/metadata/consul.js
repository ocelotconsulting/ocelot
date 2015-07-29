var cron = require('node-crontab'),
    http = require('http'),
    _ = require("underscore"),
    config = require('config');

var routes, services, routeUrl, serviceUrl;

function loadData() {
    loadJsonMetadata(routeUrl).then(function (data) {
        routes = interpretRoutes(data);
    }, function (error) {
        console.log("could not load routes: " + error)
    });
    loadJsonMetadata(serviceUrl).then(function (data) {
        services = interpretServices(data);
    }, function (error) {
        console.log("could not load services: " + error)
    });
}

function loadJsonMetadata(url) {
    return new Promise(function (resolve, reject) {
        http.get(url, function (res) {
            if (('' + res.statusCode).match(/^2\d\d$/)) {
                var data = '';
                res.on('data', function (chunk) {
                    data += chunk;
                });
                res.on('end', function () {
                    var routes = JSON.parse(data);
                    resolve(routes);
                });
            } else {
                reject('error calling ' + url)
            }
        }).end();
    });
}

interpretRoutes = function (raw) {
    var regex = /routes\/(.+)/;
    return _.filter(_.map(raw, function (obj) {
        try {
            var decoded = JSON.parse(new Buffer(obj.Value, 'base64').toString('utf8'));
            var match = regex.exec(obj.Key);
            decoded["route"] = match[1];
            return decoded;
        } catch (e) {
            return null;
        }
    }), function (obj) {
        return obj !== null;
    });
};

interpretServices = function (raw) {
    var regex = /services\/(.+)\/(.+)/;
    var filtered = _.filter(_.map(raw, function (obj) {
        if (regex.test(obj.Key)) {
            try {
                var decoded = JSON.parse(new Buffer(obj.Value, 'base64').toString('utf8'));
                var match = regex.exec(obj.Key);
                decoded["name"] = match[1];
                decoded["id"] = match[2];
                return decoded;
            } catch (e) {
                return null;
            }
        } else {
            return null
        }
    }), function (obj) {
        return obj !== null;
    });
    return _.groupBy(filtered, 'name');
};

exports.initCache = function initCron() {
    if (!config.has("backend.consul.routes") || !config.has("backend.consul.services")) {
        console.log("configuration backend.consul.routes and backend.consul.services are required when using consul as the backend");
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
