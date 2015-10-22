http = require 'http'
https = require 'https'
url = require 'url'

module.exports =
    get: (urlToGet) ->
        new Promise (resolve, reject) ->
            proto = if url.parse(urlToGet).protocol is 'https:' then https else http
            proto.get(urlToGet, (res) ->
                if ('' + res.statusCode).match /^2\d\d$/
                    data = ''
                    res.on 'data', (chunk) ->
                        data += chunk
                    res.on 'end', ->
                        routes = JSON.parse data
                        resolve routes
                else
                    reject "error calling #{urlToGet}"
            ).on('error', (e) ->
                reject "error calling: #{urlToGet}, #{e.message}"
            ).end()
