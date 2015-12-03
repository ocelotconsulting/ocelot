http = require 'http'
httpProxy = require 'http-proxy'
response = require './response'
requestHandler = require './request-handler'
express = require 'express'
facade = require './backend/facade'
bodyparser = require 'body-parser'
log = require './log'

px = httpProxy.createProxyServer {changeOrigin: true, autoRewrite: true}

px.on 'error', (err, req, res) ->
    response.send res, 500, 'Error during proxy: ' + err + ':' + err.stack

facade.init()

server = http.createServer requestHandler.create(px)
port = process.env.PORT or 8080
log.debug 'proxy listening on port ' + port
server.listen port

app = express()
app.use bodyparser.json()
apiPort = (parseInt(process.env.PORT) + 1) or 8081
app.use '/api/v1', require('./api')
log.debug 'api listening on port ' + apiPort
app.listen(apiPort);
