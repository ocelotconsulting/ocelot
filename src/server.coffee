http = require 'http'
response = require './response'
express = require 'express'
facade = require './backend/facade'
bodyparser = require 'body-parser'
log = require './log'
prometheus = require './metrics/prometheus'
ServerResponse = http.ServerResponse
config = require 'config'

if config.util.getConfigSources().length == 0
  msg = 'No server configuration found.
  Ocelot is configured using the "config" NPM package.
  Specify NODE_CONFIG_DIR and NODE_ENV or  NODE_CONFIG to
  configure using a JSON formatted environment variable.'
  throw new Error msg

facade.init()

proxyRoutes = (router) ->
  router = router or express.Router()
  router.use require './middleware/prom'
  router.use require './middleware/poweredby'
  router.use require './middleware/cors'
  router.use require './middleware/upgrade'

  # sets req.cookies by parsing the cookie header
  router.use (require 'cookie-parser')()

  # sets req._route (required), the route configuration json
  router.use require './middleware/route-resolver'

  router.use require './middleware/exchange'
  router.use require './middleware/token-refresh'
  router.use require './middleware/internal-filter'

  # sets req._auth (optional),
  # the validation response from the authentication server
  router.use require './middleware/validate-authentication'

  # sets req._profile (optional), the profile system response
  router.use require './middleware/profile'

  router.use require './middleware/token-info'
  router.use require './middleware/client-whitelist'
  router.use require './middleware/request-headers'

  # sets req._url (required), the url to the backend server
  router.use require './middleware/backend-host'

  router.use require './middleware/proxy'
  router

routeMiddleware = proxyRoutes()
proxy = express()
proxy.use routeMiddleware
proxyPort = process.env.PORT or 80
log.debug 'proxy listening on port ' + proxyPort
proxyHttpServer = proxy.listen proxyPort

proxyHttpServer.on 'upgrade', (req, socket, head) ->
  req._ws = socket
  req._head = head
  res = new ServerResponse(socket)
  res._ws = socket
  routeMiddleware req, res

api = express()
api.use bodyparser.json()
api.get '/api/v1/metrics', prometheus.metricsFunc()

api.use '/api/v1', require './middleware/cors'
api.use '/api/v1', require './middleware/api/auth-validation'
api.use '/api/v1', require './middleware/api/client-whitelist'
api.use '/api/v1', require './middleware/api/audit'

api.use '/api/v1/routes', require './api/routes'
api.use '/api/v1/hosts', require './api/hosts'

apiPort = (parseInt(process.env.PORT) + 1) or 81
log.debug 'api listening on port ' + apiPort
api.listen(apiPort)

internalRouter = express.Router()
internalRouter.use require './middleware/internalize'
proxyRoutes(internalRouter)

internalProxy = express()
internalProxy.use internalRouter
internalPort = (parseInt(process.env.PORT) + 2) or 82
log.debug 'internal route proxy listening on port ' + internalPort
internalProxy.listen internalPort

console.log """
                       (`.-,')
                     .-'     ;
                 _.-'   , `,-
           _ _.-'     .'  /._
         .' `  _.-.  /  ,'._;)
        (       .  )-| (
         )`,_ ,'_,'  \_;)
 ('_  _,'.'  (___,))
  `-:;.-'
"""
