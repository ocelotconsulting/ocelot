var url = require('url'),
    postman = require('./postman'),
    headers = require('./headers');

// todo: delegate to backend

function tryCode (req, route) {
    var parsedUrl = url.parse(req.url, true);
    var code = parsedUrl.query.code;
    var state = parsedUrl.query.state;

    var redirectUrl = new Buffer(state, 'base64').toString('utf8');

    if (redirectUrl.indexOf('?') > -1) {
        redirectUrl = redirectUrl.substring(redirectUrl.indexOf('?'));
    }

    redirectUrl = redirectUrl + "/receive-auth-token";
    redirectUrl = encodeURIComponent(redirectUrl);

    var exchangeQuery = 'grant_type=authorization_code&code=' + code + '&redirect_uri=' + redirectUrl;
    return postman.post(exchangeQuery, route);
}

exports.code = function(req, res, route){
    tryCode(req, route).then(function (result) {
        var state = url.parse(req.url, true).query.state;
        var origUrl = new Buffer(state, 'base64').toString('utf8');

        res.setHeader('Location', origUrl);
        headers.setAuthCookies(res, route, result);
        res.statusCode = 307;
        res.end();
    }, function (error) {
        console.log("Error during code exchange: " + error + "; for url: " + req.url);
        res.statusCode = 500;
        res.end();
    });
};
