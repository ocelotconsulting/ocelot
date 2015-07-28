var props = require('deep-property'),
    response = require('../response');

exports.toAuthServer = function(req, res, route){
    var reqUrl = req.url;
    if (reqUrl.charAt(reqUrl.length - 1) === '/') {
        reqUrl = reqUrl.substring(0, reqUrl.length - 1);
    }

    var host = req.headers.host;
    if (props.has(route, 'authentication.redirect-host')){
        host = props.get(route, 'authentication.redirect-host');
    }

    var origUrl = 'http://' + host + reqUrl;
    var redirectUrl = origUrl + '/receive-auth-token';
    if (redirectUrl.indexOf('?') > -1) {
        redirectUrl = redirectUrl.substring(redirectUrl.indexOf('?'));
    }
    redirectUrl = encodeURIComponent(redirectUrl);
    var state = new Buffer(origUrl).toString('base64');
    var client = props.get(route, 'authentication.client-id');
    var authServer = props.get(route, 'authentication.auth-server');
    var scope = props.get(route, 'authentication.scope');

    var location = authServer + '/as/authorization.oauth2?client_id=' + client + '&response_type=code&scope=' + encodeURIComponent(scope) + '&redirect_uri=' + redirectUrl + '&state=' + state;
    res.setHeader('Location', location);
    response.send(res, 307);
};

exports.refreshPage = function(req, res){
    var origUrl = 'http://' + req.headers.host + req.url;
    res.setHeader('Location', origUrl);
    response.send(res, 307);
};