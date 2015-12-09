https = require 'https'
url = require 'url'
config = require 'config'
_ = require 'underscore'
Promise = require 'promise'
agent = require('superagent-promise')(require('superagent'), Promise)

url = config.get 'authentication.ping.token-endpoint'

postAs = (formData, client, secret) ->
    agent
    .post url
    .type 'form'
    .send formData
    .send
        client_id: client
    .send
        client_secret: secret
    .then (res) ->
        result = try
            console.log res.text
            JSON.parse res.text
        catch e
            throw "could not parse JSON response: #{data}"

        if result.error
            throw "#{result.error} #{result['error_description']}"
        else result

post = (formData, route) ->
    postAs formData, route['client-id'], route['client-secret']

module.exports = {post, postAs}
