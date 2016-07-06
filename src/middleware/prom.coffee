promMetrics = require '../metrics/prometheus'

module.exports = (req, res, next) ->
  if not req._ws
    promMetrics.requestProcessing(req)
    res.on 'finish', ->
      promMetrics.requestFinished(req)
    res.on 'close', ->
      promMetrics.requestFinished(req)
  next()
