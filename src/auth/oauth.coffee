postman = require './postman'
config = require 'config'
cache = require 'memory-cache'
log = require '../log'
client = config.get 'authentication.validation-client'
secret = config.get 'authentication.validation-secret'
grantType = config.get 'authentication.validation-grant-type'

promisify = (thing) ->
  if not thing?
    Promise.reject()
  else
    Promise.resolve(thing)

getBearerToken = (req) ->
  getBearerTokenByHeader = (headerName) ->
    headerValue = req.headers[headerName]
    bearer = if headerValue?.slice(0, 7).toLowerCase() is 'bearer ' then headerValue.slice 7
    bearer

  promisify(getBearerTokenByHeader('alt-auth') or getBearerTokenByHeader('authorization'))

getCookieToken = (req, route, cookies) ->
  cookieName = route['cookie-name']
  token = cookies[cookieName] if cookieName
  promisify token

module.exports =
  getToken: (req, route, cookies) ->
    getBearerToken(req).catch () -> getCookieToken(req, route, cookies)

  validate: (token) ->
    cachedValidation = cache.get token
    if cachedValidation
      log.debug "cache hit for token #{token.substring(0,5)}"
      Promise.resolve cachedValidation
    else
      formData =
        grant_type: grantType
        token: token

      postman.postAs(formData, client, secret).then (authentication) ->
        log.debug "token validated #{token.substring(0,5)}"
        ttl = (authentication.expires_in * 1000) or 300000
        cache.put token, authentication, ttl
        authentication.token = token
        authentication.obtained_on = new Date().getTime()
        authentication
