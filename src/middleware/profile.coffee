profile = require '../auth/profile'
tokenProvider = require '../token-provider'
log = require '../log'

module.exports = (req, res, next) ->
  tokenProvider.getToken()
  .then (token) ->
    profile.getProfile(req._auth, req._route, token)
    .then (profile) ->
      req._profile = profile
      next()
  .catch (ex) ->
    log.error 'Could not load profile information', ex
    next()
