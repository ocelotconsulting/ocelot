var props = require('deep-property'),
    Promise = require('promise'),
    postman = require('./postman');

exports.authentication = function (req, route) {
    return new Promise(function (resolve, reject) {

        //todo: clean this crap up

        if (props.get(route, 'authentication.disabled') === true) {
            resolve({
                required: false
            });
        }

        var token = null;
        var canRefresh = false;
        var requiresCookie = props.has(route, 'authentication.cookie-name');

        if (props.has(route, 'authentication.cookie-name')) {
            token = parseCookies(req)[props.get(route, 'authentication.cookie-name')];
        }
        if (props.has(route, 'authentication.cookie-name')) {
            if (parseCookies(req)[props.get(route, 'authentication.cookie-name') + '_RT']) {
                canRefresh = true;
            }
        }

        if (props.has(req.headers['Authorization'])) {
            // matches 'Bearer <token>'
        }

        if (token == null) {
            resolve({
                required: true,
                valid: false,
                refresh: canRefresh,
                redirect: requiresCookie
            });
        }

        var validateQuery = 'grant_type=' + encodeURIComponent('urn:pingidentity.com:oauth2:grant_type:validate_bearer') + '&token=' + token;

        postman.post(validateQuery, route).then(function(result){
            result.required = true;
            result.valid = true;
            resolve(result);
        }, function(error){
            reject({
                required: true,
                valid: false,
                error: error,
                refresh: canRefresh,
                redirect: requiresCookie
            });
        });
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
