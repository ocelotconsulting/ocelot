var Promise = require('promise'),
    postman = require('./postman'),
    config = require('config'),
    cookies = require('../cookies');

var client = config.get("authentication.ping.validate.client");
var secret = config.get("authentication.ping.validate.secret");

// todo: call backend for url composition

exports.authentication = function (req, route) {
    return new Promise(function (resolve, reject) {

        if (route['require-auth'] === false) {
            resolve({});
        }

        else {
            var token = getToken(req, route);
            var refreshTokenPresent = typeof cookies.parse(req)[route['cookie-name'] + '_rt'] !== 'undefined';
            var cookieAuthEnabled = route['cookie-name'] && route['cookie-name'].length > 0;

            if (!token) {
                reject({
                    refresh: refreshTokenPresent,
                    redirect: cookieAuthEnabled
                });
            }
            else {
                var validateQuery = 'grant_type=' + encodeURIComponent('urn:pingidentity.com:oauth2:grant_type:validate_bearer') + '&token=' + token;
                postman.postAs(validateQuery, client, secret).then(function (result) {
                    result.valid = true;
                    resolve(result);
                }, function () {
                    reject({
                        refresh: refreshTokenPresent,
                        redirect: cookieAuthEnabled
                    });
                });
            }
        }
    });
};

function getToken(req, route){
    var token = null;
    if (route['cookie-name']) {
        token = cookies.parse(req)[route['cookie-name']];
    }
    if (req.headers.authorization && req.headers.authorization.toLowerCase().indexOf('bearer') > -1) {
        token = req.headers.authorization.split(' ')[1];
    }
    return token;
}
