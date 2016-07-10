log = require '../log'
user = require '../auth/user'

module.exports = (req, res, next) ->
  if not req._ws
    doAudit = ->
      metadata =
        address: req.connection.remoteAddress
        clientId: req._auth?.client_id or "unknown"
        userId: user.getUserId(req) or "unknown"
        path: req.url
        host: req.headers.host or "unknown"
        method: req.method
        proxy_path: req._url?.href or "unknown"
        status: res.statusCode
        elapsed_ms: new Date().getTime() - req._time

      log.verbose "AUDIT", metadata

    res.on 'finish', doAudit
    res.on 'close', doAudit

  next()
