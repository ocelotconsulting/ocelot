var _ = require('underscore');

exports.set = function(res, route, result){
    var cookieArray = [route.authentication['cookie-name'] + '=' + result.access_token,
        route.authentication['cookie-name'] + '_RT=' + result.refresh_token];

    var cookiePath = route.authentication['cookie-path'] || ("/" + route.route);
    cookieArray = _.map(cookieArray, function (item) {
        return item + "; path=" + cookiePath;
    });

    res.setHeader('Set-Cookie', cookieArray);
};