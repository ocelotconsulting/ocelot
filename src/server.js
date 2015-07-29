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
    config = require('config');

var px = httpProxy.createProxyServer({
    changeOrigin: true,
    autoRewrite: true
});

var server = http.createServer(function (req, res) {
    overrideHost(req);
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
        else{
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
                    if (authentication.valid && route.authentication['user-header']) {
                        req.headers[route.authentication['user-header']]= authentication.access_token.user_id;
                    }
                    if (authentication.valid && route.authentication['client-header']) {
                        req.headers[route.authentication['client-header']]= authentication.client_id;
                    }
                    proxy.request(px, req, res, url);
                }
            }, function (error, authentication) {
                console.log(error);
                console.log(authentication);
            });
        }
    }
});

// in some cases, as in aws, the host is overwritten by a different revere proxy.  since ping redirects
// are based on the host, we need to reset the host header to what it should be.
function overrideHost(req){
    if (config.get('route.host') !== "auto"){
        req.headers.host = config.get('route.host');
    }
}

console.log("listening on port 8080");

var port = 8080;
if(process.env.PORT){
    port = process.env.PORT;
}
server.listen(port);
