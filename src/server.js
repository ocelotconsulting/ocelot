var http = require('http'),
    httpProxy = require('http-proxy'),
    resolver = require('./resolver.js'),
    rewrite = require('./rewrite.js'),
    validate = require('./auth/validate.js'),
    proxy = require('./proxy.js'),
    exchange = require('./auth/exchange.js'),
    uri = require('url'),
    refresh = require('./auth/refresh');

var px = httpProxy.createProxyServer({
    hostRewrite: true,
    autoRewrite: true,
    changeOrigin: true
});

var server = http.createServer(function (req, res) {
    var route = resolver.resolveRoute(req.url);
    if (route == null) {
        res.statusCode = 404;
        res.write("Route not found");
        res.end();
        return;
    }
    else if (req.url.indexOf('receive-auth-token') > -1) {
        exchange.code(req.url).then(function (result) {
            var url_parts = uri.parse(req.url, true);
            var query = url_parts.query;
            var state = query.state;
            var origUrl = new Buffer(state, 'base64').toString('utf8');
            res.setHeader('Location', origUrl);
            res.setHeader('Set-Cookie', [route.authentication['cookie-name'] + '=' + result.access_token, route.authentication['cookie-name'] + '_RT=' + result.refresh_token]);
            res.statusCode = 307;
            res.end();
            return;
        }, function (error) {
            console.log(error);
            res.statusCode = 500;
            res.write(error);
            res.end();
            return;
        });
    }
    else {
        var url = rewrite.mapRoute(req.url, route);
        if (url == null) {
            res.statusCode = 404;
            res.write("No active URL for route");
            res.end();
            return;
        }

        validate.authentication(req, route).then(function (authentication) {
            if (authentication.refresh) {
                refresh.token(req, route).then(function(result){
                    var origUrl = 'http://' + req.headers.host + req.url;
                    res.setHeader('Location', origUrl);
                    res.setHeader('Set-Cookie', [route.authentication['cookie-name'] + '=' + result.access_token + '; path=/' + route.route, route.authentication['cookie-name'] + '_RT=' + result.refresh_token + '; path=/' + route.route]);
                    res.statusCode = 307;
                    res.end();
                    return;
                }, function(error){
                    console.log(error);
                    res.statusCode = 307;

                    //todo: allow host override for aws used in redirect uri

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

                    var location = 'https://test.amp.monsanto.com/as/authorization.oauth2?client_id=TPS_TEST&response_type=code&redirect_uri=' + redirectBack + '&state=' + state;
                    res.setHeader('Location', location);
                    res.end();
                });
            }
            else if (authentication.redirect) {
                //todo: same as refresh
                res.statusCode = 307;

                //todo: allow host override for aws used in redirect uri

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

                var location = 'https://test.amp.monsanto.com/as/authorization.oauth2?client_id=TPS_TEST&response_type=code&redirect_uri=' + redirectBack + '&state=' + state;
                res.setHeader('Location', location);
                res.end();
            }
            else if (authentication.required && !authentication.valid) {
                res.statusCode = 403;
                res.write("Authorization header missing or invalid");
                res.end();
            }
            else {
                if (authentication.required && authentication.valid) {
                    // set additional headers here
                }
                proxy.request(px, req, res, url);
            }
        }, function (error, authentication) {
            console.log(error);
            console.log(authentication);
        });
    }
});

console.log("listening on port 8080");
server.listen(8080);
