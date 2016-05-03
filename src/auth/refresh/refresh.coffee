postman = require '../postman'
crypt = require '../crypt'
log = require '../../log'

grantType = "refresh_token"

module.exports =
  accept: (route, cookies) ->
    route?['require-auth'] and route['cookie-name'] and cookies["#{route['cookie-name']}_rt"]?

  token: (req, route, cookies) ->
    log.debug 'refreshing cookie for', route.route
    cookieName = "#{route['cookie-name']}_rt"

    Promise.resolve()
    .then ->
      refreshToken = crypt.decrypt cookies[cookieName], route['client-secret']
      formData =
          grant_type: grantType
          refresh_token: refreshToken

      postman.post formData, route
