http = require 'http'

module.exports =
    get: (url) ->
        new Promise((resolve, reject) ->
            http.get(url, (res) ->
                if ('' + res.statusCode).match(/^2\d\d$/)
                    data = ''
                    res.on 'data', (chunk) ->
                        data += chunk
                    res.on 'end', ->
                        routes = JSON.parse(data)
                        resolve routes
                else
                    reject 'error calling ' + url
            ).on('error', (e) ->
                reject 'error calling: ' + url + ', ' + e.message
            ).end()
        )