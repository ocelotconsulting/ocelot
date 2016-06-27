log = require '../../log'
user = require '../../auth/user'

module.exports = (req, res, next) ->
  userId = user.getUserId(req) or "unknown"
  clientId = req._auth?.client_id
  log.debug "API_AUDIT method=#{req.method}, path=#{req.url}, client=#{clientId}, user=#{userId}"
  next()
