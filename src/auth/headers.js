var _ = require('underscore'),
    cookies = require('../cookies');

exports.setAuthCookies = function (res, route, authentication) {
    //todo: maybe hash incoming ip address along with cookie to prevent cross site scripting
    var cookieName = route['cookie-name'];
    var cookieArray = [cookieName + '=' + authentication.access_token];

    if(authentication.refresh_token){
        cookieArray[cookieArray.length] = cookieName + '_rt=' + authentication.refresh_token;
    }

    if(authentication.id_token){
        cookieArray[cookieArray.length] = cookieName + '_oidc=' + authentication.id_token;
    }

    var cookiePath = route['cookie-path'] || ("/" + route.route);
    cookieArray = _.map(cookieArray, function (item) {
        return item + "; path=" + cookiePath;
    });

    res.setHeader('Set-Cookie', cookieArray);
};

exports.addAuth = function (req, route, authentication) {
    try {
        var userHeader = route['user-header'];
        var clientHeader = route['client-header'];
        var oidc = cookies.parse(req)[route['cookie-name'] + '_oidc'];

        if (authentication.valid && userHeader && oidc) {
            var stringToParse = new Buffer(oidc.split('.')[1], 'base64').toString('utf8');
            var oidcDecoded = JSON.parse(stringToParse);
            req.headers[userHeader] = oidcDecoded.sub;
        }

        if (authentication.valid && clientHeader && authentication.client_id) {
            req.headers[clientHeader] = authentication.client_id;
        }
    }
    catch (ex) {
        console.log('error adding user/client header: ' + ex + '; ' + ex.stack);
    }
};