config = require 'config'
response = require './response'

module.exports =
  accept: (req) -> config.get('enforce-https') and req.headers['x-forwarded-proto'] != 'https' and not req.connection?.secure

  complete: (req, res) ->
    url = "https://#{req.headers.host}#{req.url}"
    res.setHeader 'Location', url
    response.send res, 307