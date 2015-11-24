https = require 'https'
url = require 'url'
config = require 'config'
_ = require 'underscore'

parsedUrl = url.parse(config.get 'authentication.ping.token-endpoint')
authHost = parsedUrl.host
authPathname = parsedUrl.pathname

postAs = (query, client, secret) ->
    new Promise (resolve, reject) ->
        processResult = (postResult) ->
            data = ''
            postResult.setEncoding 'utf8'
            postResult.on 'data', (chunk) -> data += chunk
            postResult.on 'end', ->
                result = try
                    JSON.parse data
                catch e
                    error: "could not parse JSON response: #{data}"
                if result.error
                    if result['error_description']
                        reject "#{result.error} #{result['error_description']}"
                    else
                        reject "#{result.error}"
                else resolve result

        options =
            host: authHost
            path: "#{authPathname}?#{query}"
            method: 'POST'
            headers:
                Authorization: "basic #{new Buffer(client + ':' + secret, 'utf8').toString 'base64'}"
        httpsReq = https.request options, processResult
        httpsReq.on 'error', reject
        httpsReq.end()

post = (query, route) ->
    client = route['client-id']
    secret = route['client-secret']
    postAs query, client, secret

module.exports = {post, postAs}
