config = require 'config'
httpplease = require 'httpplease'
promises = require 'httpplease-promises'
Promise = require 'promise'
agent = require('../http-agent')
xml2js = require 'xml2js'

wamConverterUrl = config.get 'wam.converter-url' if config.has 'wam.converter-url'
soapRequestTemplate = null

createSOAPReq = (token) ->
    if not soapRequestTemplate
      soapRequestTemplate = do ->
        rawTemplate = new Buffer(config.get('wam.converter-soap-req'), 'base64').toString 'utf8'
        rawTemplate.replace /WAM_CONVERTER_URL/, wamConverterUrl

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
    '_'
]

findWAMTokenInXML = (source) ->
    find = (parent, index) ->
        if not parent or index is wamTokenPath.length
            parent
        else
            find parent[wamTokenPath[index]], index + 1

    wamToken = find source, 0
    if wamToken?
        wamToken.replace /^\s+|\s+$/g, ""

handleSuccessResult = (res) ->
    result = try
        new Promise (resolve, reject) ->
            xml2js.parseString res.text, (err, result) ->
                if err then reject err else resolve findWAMTokenInXML(result)
    catch e
        throwBadHttpResponse res
    if result.error
        throwBadHttpResponse res
    else result

throwBadHttpResponse = (res) ->
    throw "HTTP #{res.statusCode}: #{res.text}"

handleErrorResult = (err) ->
    throwBadHttpResponse err.response

getWAMToken = (token) ->
    agent.getAgent().post wamConverterUrl
    .accept 'xml'
    .buffer()
    .type 'xml'
    .send createSOAPReq token
    .then handleSuccessResult, handleErrorResult

# if an error occurs this will just resolve to undefined

module.exports = {getWAMToken, findWAMTokenInXML}
