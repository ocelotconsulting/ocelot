cookie = require 'cookie'
log = require './log'

module.exports = (req) ->
    rawCookie = req.headers.cookie
    names = []
    if rawCookie
        for kv in rawCookie.split ';'
            if kv.indexOf '=' > 0
                name = kv.split('=')[0].trim()
                if names.indexOf(name) > -1
                    log.warning "Duplicate cookies exist in request #{name}: #{rawCookie}"
                else
                    names.push name

        cookie.parse rawCookie
    else {}