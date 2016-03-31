http = require 'http'
response = require './response'
express = require 'express'
facade = require './backend/facade'
bodyparser = require 'body-parser'
log = require './log'
prometheus = require './metrics/prometheus'
ServerResponse = http.ServerResponse

facade.init()

proxyMiddleware = express.Router();
proxyMiddleware.use require './middleware/prom'
proxyMiddleware.use require './middleware/poweredby'
proxyMiddleware.use require './middleware/cors'
proxyMiddleware.use require './middleware/upgrade'

proxyMiddleware.use (require 'cookie-parser')()

proxyMiddleware.use require './middleware/route-resolver'
proxyMiddleware.use require './middleware/exchange'
proxyMiddleware.use require './middleware/token-refresh'

proxyMiddleware.use require './middleware/backend-host-url'

proxyMiddleware.use require './middleware/validate-authentication'
proxyMiddleware.use require './middleware/token-info'
proxyMiddleware.use require './middleware/client-whitelist'
proxyMiddleware.use require './middleware/request-headers'
proxyMiddleware.use require './middleware/proxy'

proxy = express()
proxy.use proxyMiddleware
proxyPort = process.env.PORT or 80
log.debug 'proxy listening on port ' + proxyPort
proxyHttpServer = proxy.listen proxyPort

proxyHttpServer.on 'upgrade', (req, socket, head) ->
  req._ws = socket
  req._head = head
  res = new ServerResponse(socket)
  res._ws = socket
  proxyMiddleware req, res

api = express()
api.use bodyparser.json()
api.get '/api/v1/metrics', prometheus.metricsFunc()
api.use '/api/v1', require './api/validate-api-user'
api.use '/api/v1/routes', require './api/routes'
api.use '/api/v1/hosts', require './api/hosts'

apiPort = (parseInt(process.env.PORT) + 1) or 81
log.debug 'api listening on port ' + apiPort
api.listen(apiPort);
