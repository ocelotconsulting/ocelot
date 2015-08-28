var response = require('../response'),
    config = require('config');

exports.toAuthServer = function(req, res, route){
    var host = req.headers.host;

    var origUrl = 'http://' + host + req.url;
    var redirectUrl = origUrl + '/receive-auth-token';
    if (redirectUrl.indexOf('?') > -1) {
        redirectUrl = redirectUrl.substring(redirectUrl.indexOf('?'));
    }
    var state = new Buffer(origUrl).toString('base64');
    var client = route['client-id'];
    var authServer = config.get('authentication.ping.host');
    var scope = route['oidc-scope'];

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