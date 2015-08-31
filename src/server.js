var http = require('http'),
    httpProxy = require('http-proxy'),
    response = require('./response'),
    requestHandler = require('./request-handler');

var px = httpProxy.createProxyServer({
    changeOrigin: true,
    autoRewrite: true
});

px.on('error', function (err, req, res) {
    response.send(res, 500, "Error during proxy: " + err + ":" + err.stack);
});

var server = http.createServer(requestHandler.create(px));

var port = process.env.PORT || 8080;
console.log("listening on port " + port);
server.listen(port);
