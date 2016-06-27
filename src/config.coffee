config = require 'config'

module.exports =
  get: (name) -> if config.has name then config.get name else undefined
