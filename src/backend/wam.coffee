config = require 'config'
httpplease = require 'httpplease'
promises = require 'httpplease-promises'
http = httpplease.use promises(Promise)
xml2js = require 'xml2js'

wamConverterUrl = config.get 'wam.converter-url'

soapRequestTemplate = do ->
    rawTemplate = new Buffer(config.get('wam.converter-soap-req'), 'base64').toString 'utf8'
    rawTemplate.replace /WAM_CONVERTER_URL/, wamConverterUrl

createSOAPReq = (token) ->
    base64Token = new Buffer(token, 'utf8').toString 'base64'
    soapRequestTemplate.replace /BASE64_ENCODED_OAUTH_TOKEN/, base64Token

wamTokenPath = [
    's:Envelope'
    's:Body'
    0
    'wst13:RequestSecurityTokenResponseCollection'
    0
    'wst13:RequestSecurityTokenResponse'
    0
    'wst13:RequestedSecurityToken'
    0
    'wsse:BinarySecurityToken'
    0
    #NOTE - original path ended in '_'.  looks like a mistake from what i can see
]

findWAMTokenInXML = (source) ->
    find = (parent, index) ->
        if not parent or index is wamTokenPath.length
            parent
        else
            find parent[wamTokenPath[index]], index + 1

    find source, 0

# if an error occurs this will just resolve to undefined
getWAMToken = (token) ->
    options =
        method: 'post'
        url : wamConverterUrl
        body : createSOAPReq token
    http(options).then (resp) ->
        if resp.status is 200
            new Promise (resolve) ->
                # according to xml2s docs you're not supposed to rely on sync execution
                xml2js.parseString resp.body, (err, result) ->
                    resolve findWAMTokenInXML(result)

module.exports = {getWAMToken, findWAMTokenInXML}
