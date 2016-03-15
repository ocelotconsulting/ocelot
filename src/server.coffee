http = require 'http'
httpProxy = require 'http-proxy'
response = require './response'
requestHandler = require './request-handler'
express = require 'express'
facade = require './backend/facade'
bodyparser = require 'body-parser'
log = require './log'
prometheus = require './metrics/prometheus'
ServerResponse = http.ServerResponse

px = httpProxy.createProxyServer {changeOrigin: true, autoRewrite: true, ws: true}

px.on 'error', (err, req, res) ->
    response.send res, 500, 'Error during proxy: ' + err + ':' + err.stack

facade.init()

requestHandler = requestHandler.create(px)
proxyServer = http.createServer requestHandler
proxyPort = process.env.PORT or 80
log.debug 'proxy listening on port ' + proxyPort
proxyServer.listen proxyPort

proxyServer.on 'upgrade', (req, socket, head) ->
  req._ws = socket
  req._head = head
  res = new ServerResponse(socket)
  res._ws = socket
  requestHandler req, res

api = express()
api.use bodyparser.json()
api.get '/api/v1/metrics', prometheus.metricsFunc()
api.use '/api/v1', require './api/validate-api-user'
api.use '/api/v1/routes', require './api/routes'
api.use '/api/v1/hosts', require './api/hosts'

apiPort = (parseInt(process.env.PORT) + 1) or 81
log.debug 'api listening on port ' + apiPort
api.listen(apiPort);
