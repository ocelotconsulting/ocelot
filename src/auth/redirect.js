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

    var origUrl = 'http://' + host + req.url;
    var redirectUrl = origUrl + '/receive-auth-token';
    if (redirectUrl.indexOf('?') > -1) {
        redirectUrl = redirectUrl.substring(redirectUrl.indexOf('?'));
    }
    var state = new Buffer(origUrl).toString('base64');
    var client = props.get(route, 'authentication.client-id');
    var authServer = props.get(route, 'authentication.auth-server');
    var scope = props.get(route, 'authentication.scope');

    var location = authServer + '/as/authorization.oauth2?' +
        'response_type=code' +
        addQueryParam("client_id", client) +
        addQueryParam("redirect_uri", redirectUrl) +
        addQueryParam("state", state) +
        addQueryParam("scope", scope);
    res.setHeader('Location', location);
    response.send(res, 307);
};

var addQueryParam = function(key, value) { return ((value) ? "&" + key + "=" + encodeURIComponent(value) : "")};

exports.refreshPage = function(req, res){
    var origUrl = 'http://' + req.headers.host + req.url;
    res.setHeader('Location', origUrl);
    response.send(res, 307);
};