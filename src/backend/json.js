var http = require("http");

exports.get = function get(url) {
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
                reject('error calling ' + url);
            }
        }).on('error', function (e) {
            reject("error calling: " + url + ", " + e.message);
        }).end();
    });
};