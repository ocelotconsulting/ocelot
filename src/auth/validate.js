var Promise = require('promise'),
    postman = require('./postman'),
    config = require('config'),
    cookies = require('../cookies');

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
            var requiresCookie = typeof route['cookie-name'] !== 'undefined' && route['cookie-name'].length > 0;
            var myCookies = cookies.parse(req);
            if (route['cookie-name']) {
                token = myCookies[route['cookie-name']];
                if (myCookies[route['cookie-name'] + '_rt']) {
                    canRefresh = true;
                }
            }
            if (req.headers.authorization && req.headers.authorization.toLowerCase().indexOf('bearer') > -1) {
                token = req.headers.authorization.split(' ')[1];
            }
            if (!token) {
                reject({
                    required: true,
                    valid: false,
                    refresh: canRefresh,
                    redirect: requiresCookie
                });
            }
            else {
                var validateQuery = 'grant_type=' + encodeURIComponent('urn:pingidentity.com:oauth2:grant_type:validate_bearer') + '&token=' + token;
                postman.postAs(validateQuery, client, secret).then(function (result) {
                    result.required = true;
                    result.valid = true;
                    resolve(result);
                }, function (error) {
                    reject({
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
