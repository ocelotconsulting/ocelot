var props = require('deep-property'),
    Promise = require('promise'),
    postman = require('./postman'),
    config = require('config');

var client = config.get("authentication.ping.validate.client");
var secret = config.get("authentication.ping.validate.secret");

exports.authentication = function (req, route) {
    return new Promise(function (resolve, reject) {
        //todo: clean this crap up
        if (route['require-auth'] === false) {
            resolve({
                required: false
            });
        }
        else {
            var token = null;
            var canRefresh = false;
            var requiresCookie = route['cookie-name'];
            var cookies = parseCookies(req);
            if (route['cookie-name']) {
                token = cookies[route['cookie-name']];
                if (cookies[route['cookie-name'] + '_RT']) {
                    canRefresh = true;
                }
            }
            if (req.headers.authorization && req.headers.authorization.toLowerCase().indexOf('bearer') > -1) {
                token = req.headers.authorization.split(' ')[1];
            }
            if (!token) {
                resolve({
                    required: true,
                    valid: false,
                    refresh: canRefresh,
                    redirect: requiresCookie
                });
            }
            else {
                var validateQuery = 'grant_type=' + encodeURIComponent('urn:pingidentity.com:oauth2:grant_type:validate_bearer') + '&token=' + token;
                postman.post(validateQuery, route, client, secret).then(function (result) {
                    result.required = true;
                    result.valid = true;
                    resolve(result);
                }, function (error) {
                    resolve(error, {
                        required: true,
                        valid: false,
                        error: error,
                        refresh: canRefresh,
                        redirect: requiresCookie
                    });
                });
            }
        }
    });
};

function parseCookies(req) {
    var list = {},
        rc = req.headers.cookie;

    rc && rc.split(';').forEach(function (cookie) {
        var parts = cookie.split('=');
        list[parts.shift().trim()] = decodeURI(parts.join('='));
    });

    return list;
}
