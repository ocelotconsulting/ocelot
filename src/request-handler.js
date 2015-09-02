var resolver = require('./resolver.js'),
    rewrite = require('./rewrite.js'),
    validate = require('./auth/validate.js'),
    proxy = require('./proxy.js'),
    exchange = require('./auth/exchange.js'),
    refresh = require('./auth/refresh'),
    response = require('./response.js'),
    config = require('config'),
    redirect = require('./auth/redirect.js'),
    cors = require('./cors'),
    headers = require('./auth/headers');

exports.create = function (px) {

    var host = config.get('route.host');
    var presumeHost = function (req) {
    };
    if (host !== "auto") {
        presumeHost = function (req) {
            req.headers.host = host;
        }
    }

    return function (req, res) {
        cors.setCorsHeaders(req, res);
        if (cors.preflight(req)) {
            response.send(res, 204);
            return;
        }

        presumeHost(req);

        var route = resolver.resolveRoute(req.url);

        if (route == null) {
            response.send(res, 404, "Route not found");
        }
        else if (req.url.indexOf('receive-auth-token') > -1) {
            exchange.code(req, res, route);
        }
        else {
            var url = rewrite.mapRoute(req.url, route);
            if (url == null) {
                response.send(res, 404, "No active URL for route");
            }
            else {
                validate.authentication(req, route).then(function (authentication) {
                        headers.addAuth(req, route, authentication);
                        proxy.request(px, req, res, url);
                    },
                    function (authentication) {
                        if (authentication.refresh) {
                            refresh.token(req, res, route);
                        }
                        else if (authentication.redirect) {
                            redirect.toAuthServer(req, res, route);
                        }
                        else {
                            response.send(res, 403, "Authorization missing or invalid");
                        }
                    });
            }
        }
    };
};