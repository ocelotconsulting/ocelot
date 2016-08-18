log = require '../log'
context = require '../auth/context'

module.exports = (req, res, next) ->
  if not req._ws
    doAudit = ->
      metadata =
        address: req.header('x-forwarded-for') or req.connection.remoteAddress or "unknown"
        clientId: context.getClientId(req) or "unknown"
        userId: context.getUserId(req) or "unknown"
        path: req.url
        host: req.headers.host or "unknown"
        method: req.method
        proxy_path: req._url?.href or "unknown"
        status: res.statusCode
        elapsed_ms: new Date().getTime() - req._time
        routeKey: req._route?.route or "unknown"

      log.verbose "AUDIT", metadata

    res.on 'finish', doAudit
    res.on 'close', doAudit

  next()
