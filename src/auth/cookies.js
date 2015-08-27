var _ = require('underscore');

exports.set = function (res, route, authentication) {
    //todo: maybe hash incoming ip address along with cookie to prevent cross site scripting
    var cookieName = route['cookie-name'];
    var cookieArray = [cookieName + '=' + authentication.access_token,
        cookieName + '_rt=' + authentication.refresh_token,
        cookieName + '_oidc=' + authentication.id_token];

    var cookiePath = route['cookie-path'] || ("/" + route.route);
    cookieArray = _.map(cookieArray, function (item) {
        return item + "; path=" + cookiePath;
    });

    res.setHeader('Set-Cookie', cookieArray);
};

exports.parse = function parseCookies(req) {
    var list = {},
        rc = req.headers.cookie;

    rc && rc.split(';').forEach(function (cookie) {
        var parts = cookie.split('=');
        list[parts.shift().trim()] = decodeURI(parts.join('='));
    });
    return list;
};