config = require 'config'
response = require './response'

## todo: rename this.. not a real http upgrade
module.exports =
  # and not req.connection?.secure
  accept: (req) -> config.get('enforce-https') and req.headers['x-forwarded-proto'] and req.headers['x-forwarded-proto'] != 'https'

  complete: (req, res) ->
    url = "https://#{req.headers.host}#{req.url}"
    res.setHeader 'Location', url
    response.send res, 307
