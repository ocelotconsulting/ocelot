var _ = require('underscore');

exports.set = function (res, route, authentication) {
    var cookieArray = [route.authentication['cookie-name'] + '=' + authentication.access_token,
        route.authentication['cookie-name'] + '_RT=' + authentication.refresh_token];

    var cookiePath = route.authentication['cookie-path'] || ("/" + route.route);
    cookieArray = _.map(cookieArray, function (item) {
        return item + "; path=" + cookiePath;
    });

    res.setHeader('Set-Cookie', cookieArray);
};