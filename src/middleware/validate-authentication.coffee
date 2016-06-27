authCodeRefresh = require '../auth/refresh/auth-code-refresh'
redirect = require '../auth/redirect'
response = require '../response'
validate = require '../auth/validate'

module.exports = (req, res, next) ->
  route = req._route
  cookies = req.cookies

  authAccepted = (auth) ->
    req._auth = auth
    next()

  authRejected = () ->
      if authCodeRefresh.accept route, cookies
          authCodeRefresh.complete req, res, route, cookies
      else if redirect.accept route
          redirect.startAuthCode req, res, route
      else
          response.send res, 401, 'Unauthorized'

  validate.authentication(req, route, cookies).then authAccepted, authRejected
