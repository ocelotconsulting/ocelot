postman = require './postman'
config = require 'config'
cache = require 'memory-cache'
Promise = require 'promise'
client = config.get 'authentication.validation-client'
secret = config.get 'authentication.validation-secret'
grantType = 'urn:pingidentity.com:oauth2:grant_type:validate_bearer'

promisify = (thing) ->
  if not thing?
      Promise.reject()
  else
      Promise.resolve(thing)

getBearerToken = (req) ->
  {authorization} = req.headers
  bearer = if authorization?.slice(0, 7).toLowerCase() is 'bearer ' then authorization.slice 7
  promisify bearer

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
      Promise.resolve cachedValidation
    else
      formData =
        grant_type: grantType
        token: token

      postman.postAs(formData, client, secret).then (authentication) ->
        cache.put token, authentication, 300000
        authentication
