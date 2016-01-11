https = require 'https'
url = require 'url'
config = require 'config'
_ = require 'underscore'
Promise = require 'promise'
agent = require('superagent-promise')(require('superagent'), Promise)

url = config.get 'authentication.token-endpoint'

throwBadHttpResponse = (res) ->
    throw "HTTP #{res.statusCode}: #{res.text}"

handleSuccessResult = (res) ->
    result = try
        JSON.parse res.text
    catch e
        throwBadHttpResponse res
    if result.error
        throwBadHttpResponse res
    else result

handleErrorResult = (err) ->
    throwBadHttpResponse err.response

postAs = (formData, client, secret) ->
    agent
    .post url
    .type 'form'
    .send formData
    .send
        client_id: client
    .send
        client_secret: secret
    .then handleSuccessResult, handleErrorResult

post = (formData, route) ->
    postAs formData, route['client-id'], route['client-secret']

module.exports = {post, postAs}
