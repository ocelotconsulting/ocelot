var props = require('deep-property'),
    postman = require('./postman');

exports.token = function (req, route) {
    var refreshToken = parseCookies(req)[props.get(route, 'authentication.cookie-name') + '_RT'];
    var refreshQuery = 'grant_type=refresh_token&refresh_token=' + refreshToken;
    var clientId = props.get(route, 'authentication.client-id');
    var clientSecret = props.get(route, 'authentication.client-secret');

    return postman.post(refreshQuery, clientId, clientSecret);
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
