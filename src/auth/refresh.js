var props = require('deep-property'),
    postman = require('./postman');

exports.token = function (req, route) {
    var refreshToken = parseCookies(req)[props.get(route, 'authentication.cookie-name') + '_RT'];
    var refreshQuery = 'grant_type=refresh_token&refresh_token=' + refreshToken;

    return postman.post(refreshQuery, route);
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
