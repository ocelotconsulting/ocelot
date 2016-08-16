winston = require 'winston'
config = require './config'
moment = require 'moment'
BulkWriter = require 'winston-elasticsearch/bulk_writer'

# fixing a bug in winston-elasticsearch
# without this, any error writing to es
# is non recoverable
BulkWriter.prototype.tick = () ->
  thiz = this;
  if not this.running
    Promise.resolve()
  else
    this.flush()
    .catch (e) =>
      console.log 'unable to write to elasticsearch'
    .then () =>
      thiz.schedule()

console.log 'Initializing Console log transport'
transports = [new winston.transports.Console(
  timestamp: -> Date.now()
  formatter: (options) ->
    meta = JSON.stringify(options.meta) if(options.meta? and Object.keys(options.meta).length > 0)
    "#{moment(options.timestamp.time).format()} #{options.level.toUpperCase()} #{options.message} #{meta or ''}"
  )]

esSettings = config.get 'log.es'
if esSettings
  esSettings.transformer = require './es-transformer'
  Elasticsearch = require 'winston-elasticsearch'

  transports.push new Elasticsearch(esSettings)
  console.log 'Initializing Elasticsearch log transport'

winstonOpts =
  level: config.get['log.level'] or 'debug'
  transports: transports

logger = new winston.Logger(winstonOpts)
logger.on 'error', (err) ->
  console.error 'err', err

module.exports = logger
