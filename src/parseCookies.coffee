cookie = require 'cookie'

module.exports = (req) ->
    rawCookie = req.headers.cookie
    if rawCookie then cookie.parse rawCookie else {}
