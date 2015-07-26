var props = require('deep-property'),
    url = require('url'),
    postman = require('./postman');

exports.code = function (req, route) {
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
    var clientId = props.get(route, 'authentication.client-id');
    var clientSecret = props.get(route, 'authentication.client-secret');

    return postman.post(exchangeQuery, clientId, clientSecret);
};
