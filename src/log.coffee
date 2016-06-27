Log = require 'log'
config = require 'config'

module.exports = new Log(config.get['log-level'] or 'debug')