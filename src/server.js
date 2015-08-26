var http = require('http'),
    httpProxy = require('http-proxy'),
    resolver = require('./resolver.js'),
    rewrite = require('./rewrite.js'),
    validate = require('./auth/validate.js'),
    proxy = require('./proxy.js'),
    exchange = require('./auth/exchange.js'),
    refresh = require('./auth/refresh'),
    response = require('./response.js'),
    redirect = require('./auth/redirect.js'),
    config = require('config'),
    cors = require('./cors');

var px = httpProxy.createProxyServer({
    changeOrigin: true,
    autoRewrite: true
});

px.on('error', function (err, req, res) {
    response.send(res, 500, "Error during proxy: " + err + ":" + err.stack);
});

var server = http.createServer(function (req, res) {
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
                if (authentication.refresh) {
                    refresh.token(req, res, route);
                }
                else if (authentication.redirect) {
                    redirect.toAuthServer(req, res, route);
                }
                else if (authentication.required && !authentication.valid) {
                    response.send(res, 403, "Authorization missing or invalid");
                }
                else {
                    addAuthenticationHeaders(req, route, authentication);
                    proxy.request(px, req, res, url);
                }
            });
        }
    }
});

function addAuthenticationHeaders(req, route, authentication) {
    try {
        var userHeader = route['user-header'];
        var clientHeader = route['client-header'];

        var cookies = parseCookies(req);
        var oidc = cookies[route['cookie-name'] + '_oidc'];

        if (authentication.valid && userHeader && oidc) {
            var oidcDecoded = JSON.parse(new Buffer(oidc.split('.')[1], 'base64').toString('utf8'));
            req.headers[userHeader] = oidcDecoded.sub;
        }
        if (authentication.valid && clientHeader) {
            req.headers[clientHeader] = authentication.client_id;
        }
    }
    catch (ex) {
        console.log('error adding user/client header: ' + ex + '; ' + ex.stack);
    }
}

function parseCookies(req) {
    var list = {},
        rc = req.headers.cookie;

    rc && rc.split(';').forEach(function (cookie) {
        var parts = cookie.split('=');
        list[parts.shift().trim()] = decodeURI(parts.join('='));
    });
    return list;
}

function presumeHost(req) {
    if (config.get('route.host') !== "auto") {
        req.headers.host = config.get('route.host');
    }
}

var port = process.env.PORT || 8080;
console.log("listening on port " + port);
server.listen(port);
