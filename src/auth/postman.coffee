https = require 'https'
url = require 'url'
config = require 'config'
_ = require 'underscore'

finishPromise = ->
    try
        result = JSON.parse(this.data)
        if !result.error
            this.resolve result
        else
            this.reject result.error
    catch err
        this.reject 'could not parse JSON response: ' + this.data

processResult = (postres) ->
    data = ''
    postres.setEncoding 'utf8'
    postres.on 'data', (chunk) ->
        data = data + chunk
    postres.on 'end', finishPromise.bind(_.extend this, {data: data})

#todo: delegate to auth backend for url composition
doPost = (query, client, secret) ->
    new Promise((resolve, reject) ->
        options =
            host: url.parse(config.get('authentication.ping.host')).host
            path: '/as/token.oauth2?' + query
            method: 'POST'
            headers: Authorization: 'basic ' + new Buffer(client + ':' + secret, 'utf8').toString('base64')
        httpsReq = https.request options, processResult.bind(_.extend {}, {resolve: resolve, reject: reject})
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