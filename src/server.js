var http = require('http'),
  httpProxy = require('http-proxy'),
  resolver = require('./resolver.js'),
  rewrite = require('./rewrite.js');

var proxy = httpProxy.createProxyServer({});

var server = http.createServer(function(req, res) {
  var route = resolver.resolveRoute(req.url);
  if(route == null){
      res.statusCode = 404;
      res.write("Route not found");
      res.end();
      return;
  }
  var url = rewrite.mapRoute(req.url, route);
  if(url == null){
    res.statusCode = 404;
    res.write("No active URL for route");
    res.end();
    return;
  }

  req.url = url.pathname;

  // todo: use request buffer & callback when doing token verification
  proxy.web(req, res, {
    target: url.protocol + "//" + url.host
  });
  proxy.on('error', function(e) {
    console.log(new Date().toJSON().slice(0,19) + "  Error running " + url.href + ": " + e)
  });
});

console.log("listening on port 8080")
server.listen(8080);
