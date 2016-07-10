winston = require 'winston'
Elasticsearch = require 'winston-elasticsearch'
config = require './config'
moment = require 'moment'

console.log 'Initializing Console log transport'
transports = [new winston.transports.Console(
  timestamp: -> Date.now()
  formatter: (options) ->
    meta = JSON.stringify(options.meta) if(options.meta? and Object.keys(options.meta).length > 0)
    "#{moment(options.timestamp.time).format()} #{options.level.toUpperCase()} #{options.message} #{meta or ''}"
  )]

esSettings = config.get 'log.es'
if esSettings
  transports.push new Elasticsearch(esSettings)
  console.log 'Initializing Elasticsearch log transport'

winstonOpts =
  level: config.get['log-level'] or 'debug'
  transports: transports

module.exports = new winston.Logger(winstonOpts)
