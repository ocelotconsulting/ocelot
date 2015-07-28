var props = require('deep-property'),
    postman = require('./postman'),
    redirect = require('./redirect');

function tryToken (req, route) {
    var refreshToken = parseCookies(req)[props.get(route, 'authentication.cookie-name') + '_RT'];
    var refreshQuery = 'grant_type=refresh_token&refresh_token=' + refreshToken;

    return postman.post(refreshQuery, route);
}

exports.token = function(req, res, route){
    tryToken(req, route).then(function(result){

        var cookieArray = [route.authentication['cookie-name'] + '=' + result.access_token + '; path=/' + route.route,
            route.authentication['cookie-name'] + '_RT=' + result.refresh_token + '; path=/' + route.route];

        if (result.id_token) { cookieArray.concat(route.authentication['oidc-cookie-name'] + '_RT=' + result.id_token + '; path=/' + route.route); }

        res.setHeader('Set-Cookie', [cookieArray]);

        redirect.refreshPage(req, res);
    }, function(error){
        console.log(error);
        redirect.toAuthServer(req, res, route);
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
