var url = require('url'),
    postman = require('./postman');

function tryCode (req, route) {
    var url_parts = url.parse(req.url, true);
    var query = url_parts.query;
    var code = query.code;
    var state = query.state;

    var pingRedirect = new Buffer(state, 'base64').toString('utf8');
    if (pingRedirect.indexOf('?') > -1) {
        pingRedirect = pingRedirect.substring(pingRedirect.indexOf('?'));
    }
    pingRedirect = pingRedirect + "/receive-auth-token";
    pingRedirect = encodeURIComponent(pingRedirect);

    var exchangeQuery = 'grant_type=authorization_code&code=' + code + '&redirect_uri=' + pingRedirect;

    return postman.post(exchangeQuery, route);
}

exports.code = function(req, res, route){
    tryCode(req, route).then(function (result) {
        var url_parts = url.parse(req.url, true);
        var query = url_parts.query;
        var state = query.state;
        var origUrl = new Buffer(state, 'base64').toString('utf8');
        res.setHeader('Location', origUrl);
        res.setHeader('Set-Cookie', [route.authentication['cookie-name'] + '=' + result.access_token, route.authentication['cookie-name'] + '_RT=' + result.refresh_token]);
        res.statusCode = 307;
        res.end();
    }, function (error) {
        console.log(error);
        res.statusCode = 500;
        res.write(error);
        res.end();
    });
};
