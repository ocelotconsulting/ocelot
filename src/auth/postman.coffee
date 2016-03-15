agent = require('../http-agent')
config = require 'config'
url = config.get 'authentication.token-endpoint'

throwBadHttpResponse = (res) ->
    throw "HTTP #{res.statusCode}: #{res.text}"

handleSuccessResult = (res) ->
    if not res.body or res.body.error
        throwBadHttpResponse res
    else
      res.body

postAs = (formData, client, secret) ->
    agent.getAgent().post url
    .type 'form'
    .send formData
    .send
        'client_id': client
        'client_secret': secret
    .then handleSuccessResult, (err) ->
        throwBadHttpResponse err.response

post = (formData, route) ->
    postAs formData, route['client-id'], route['client-secret']

module.exports = {post, postAs}
