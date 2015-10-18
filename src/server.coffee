http = require 'http'
httpProxy = require 'http-proxy'
response = require './response'
requestHandler = require './request-handler'

px = httpProxy.createProxyServer {changeOrigin: true, autoRewrite: true}

px.on 'error', (err, req, res) ->
    response.send res, 500, 'Error during proxy: ' + err + ':' + err.stack

server = http.createServer requestHandler.create(px)
port = process.env.PORT or 8080
console.log 'listening on port ' + port
server.listen port
