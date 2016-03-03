cron = require 'node-crontab'
_ = require 'underscore'
config = require 'config'
Promise = require 'promise'
agent = require '../http-agent'
jwt = require 'jsonwebtoken'
NodeRSA = require 'node-rsa'
cache = require 'memory-cache'
jwksUrl = undefined

promisify = (thing) ->
  if not thing?
    Promise.reject()
  else
    Promise.resolve(thing)

module.exports =
    init: ->
        reloadData = ->
            agent.getAgent().get(jwksUrl).then (res) ->
              res.body.keys.forEach (key) ->
                cache.put(key.kid, key, 86400000)
            .catch (error) ->
              console.log 'could not load JWKS keys: ', error
        jwksUrl = config.get 'jwks.url'
        reloadData()
        cron.scheduleJob '*/5 * * * * *', reloadData

    validate: (token) ->
      try
        parts = token.split "."
        header = JSON.parse(new Buffer(parts[0], 'base64').toString('utf8'))
        key = cache.get(header.kid)
        if key
          publicKey = new NodeRSA()
          publicKey.importKey { n: new Buffer(key.n, 'base64'), e: parseInt(new Buffer(key.e, 'base64').toString('hex'), 16)}, 'components-public'
          publicComponents = publicKey.exportKey('pkcs1-pe-public')
          jwt.verify token, publicComponents, { algorithms: ['RS256'] }
          claims = JSON.parse(new Buffer(parts[1], 'base64').toString('utf8'))
          Promise.resolve claims
        else
          Promise.reject({invalid_oidc: true})
      catch e
        console.log 'error validating jwt: ', e
        Promise.reject({invalid_oidc: true})

    getToken: (req, route, cookies) ->
      token = if req.headers['oidc']
          req.headers['oidc']
        else if route?['cookie-name']
          cookies["#{route['cookie-name']}_oidc"]

      promisify token
