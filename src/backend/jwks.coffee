cron = require 'node-crontab'
Promise = this.Promise || require('promise');
agent = require('superagent-promise')(require('superagent'), Promise)
_ = require 'underscore'
config = require 'config'
forge = require 'node-forge'
log = require '../log'

keys = undefined
jwksUrl = undefined

reloadData = ->
    agent.get(jwksUrl).then ((data) ->
        keys = parseJWKS(data.text)
    ), (error) ->
        log.debug 'could not load JWKS keys: ' + error

parseJson = (jwksJSON, keyRegex, mutate) ->
    _(jwksJSON).chain().map((item) ->
        try
            if keyRegex.test(item.Key)
                decodedValue = JSON.parse(new Buffer(item.Value, 'base64').toString('utf8'))
                match = keyRegex.exec(item.Key)
                mutate(decodedValue, match)
        catch e
            log.debug 'error parsing: ' + item.Key
    ).compact().value()

parseJWKS = (jwksJSON) ->
    _(jwksJSON.keys).chain().map((key) -> [key.kid, key]).object().value()

validateToken = (token) ->
    log.debug "Starting oidc validation"
    parts = token.split "."
    log.debug "Split parts, going to look for #{JSON.parse(new Buffer(parts[0], 'base64').toString('utf8')).kid}"
    key = keys[JSON.parse(new Buffer(parts[0], 'base64').toString('utf8')).kid]
    if key
        log.debug "All keys = #{JSON.stringify(keys)}"
        log.debug "Retrieved specific key #{key}"
        pubKey = forge.pki.setRsaPublicKey(key.n, key.e)
        log.debug "Created public key"
        md = parts[0] + "." + parts[1]
        signature = parts[2]
        log.debug "About to verify"
        valid = pubKey.verify(md, signature)
        log.debug "Was OIDC validated? #{valid}"
        valid
    else
        false

module.exports =
    init: ->
        jwksUrl = config.get 'jwks.url'
        reloadData()
        cron.scheduleJob '*/20 * * * * *', reloadData
    getKeys: ->
        keys
    reloadData: reloadData
    validateToken: validateToken