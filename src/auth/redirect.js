var props = require('deep-property'),
    response = require('../response');

exports.toAuthServer = function(req, res, route){
    var reqUrl = req.url;
    if (reqUrl.charAt(reqUrl.length - 1) === '/') {
        reqUrl = reqUrl.substring(0, reqUrl.length - 1);
    }
    var origUrl = 'http://' + req.headers.host + reqUrl;

    var redirectBack = origUrl + '/receive-auth-token';
    if (redirectBack.indexOf('?') > -1) {
        redirectBack = redirectBack.substring(redirectBack.indexOf('?'));
    }
    redirectBack = encodeURIComponent(redirectBack);
    var state = new Buffer(origUrl).toString('base64');
    var client = props.get(route, 'authentication.client-id');
    var location = 'https://test.amp.monsanto.com/as/authorization.oauth2?client_id=' + client + '&response_type=code&redirect_uri=' + redirectBack + '&state=' + state;

    //todo: allow host override for aws used in redirect uri

    res.setHeader('Location', location);

    response.respond(res, 307);
};

exports.refreshPage = function(req, res){
    var origUrl = 'http://' + req.headers.host + req.url;
    res.setHeader('Location', origUrl);
    response.respond(res, 307);
};