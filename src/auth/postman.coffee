https = require 'https'
url = require 'url'
config = require 'config'

#todo: delegate to auth backend for url composition
doPost = (query, client, secret) ->
    new Promise((resolve, reject) ->
        options =
            host: url.parse(config.get('authentication.ping.host')).host
            path: '/as/token.oauth2?' + query
            method: 'POST'
            headers: Authorization: 'basic ' + new Buffer(client + ':' + secret, 'utf8').toString('base64')
        httpsReq = https.request(options, (postres) ->
            data = ''
            postres.setEncoding 'utf8'
            postres.on 'data', (chunk) ->
                data = data + chunk
            postres.on 'end', ->
                try
                    result = JSON.parse(data)
                    if !result.error
                        resolve result
                    else
                        reject result.error
                catch err
                    reject 'could not parse JSON response: ' + data
        )
        httpsReq.on 'error', (error) ->
            reject error
        httpsReq.end()
    )

module.exports =
    post: (query, route) ->
        client = route['client-id']
        secret = route['client-secret']
        doPost query, client, secret
    postAs: (query, client, secret) ->
        doPost query, client, secret