_ = require 'underscore'
config = require 'config'
httpplease = require 'httpplease'
promises = require 'httpplease-promises'
Promise = require('bluebird')
http = httpplease.use promises(Promise)
xml2js = require 'xml2js'

createSOAPReq = (token, url) ->
    new Buffer(config.get('wam.converter-soap-req'), 'base64').toString('utf8').replace(/BASE64_ENCODED_OAUTH_TOKEN/, new Buffer(token, 'utf8').toString('base64')).replace(/WAM_CONVERTER_URL/, url)

findWAMToken = (source) ->
    source?["s:Envelope"]?["s:Body"]?[0]?["wst13:RequestSecurityTokenResponseCollection"]?[0]?["wst13:RequestSecurityTokenResponse"]?[0]?["wst13:RequestedSecurityToken"]?[0]?["wsse:BinarySecurityToken"]?[0]._

getWAMToken = (token) ->
    options =
        method: 'post'
        url : config.get 'wam.converter-url'
        body : createSOAPReq token, config.get 'wam.converter-url'
    http(options).then (resp) ->
        if (resp.status == 200)
            wamToken = ""
            xml2js.parseString resp.body, (err, result) ->
                wamToken = findWAMToken result
            wamToken
        else
            undefined
    .catch (err) ->
        {name : err.name, message : err.message}
module.exports =
    getWAMToken: getWAMToken