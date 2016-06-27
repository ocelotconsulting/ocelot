crypto = require 'crypto'
algorithm = 'aes-256-ctr'

module.exports =
    encrypt: (text, secret) ->
        cipher = crypto.createCipher(algorithm, secret.toString('binary'))
        cipher.update(text, 'utf8', 'hex') + cipher.final('hex')
    decrypt: (text, secret) ->
        decipher = crypto.createDecipher(algorithm, secret.toString('binary'))
        decipher.update(text, 'hex', 'utf8') + decipher.final('utf8')
# Adapted from https://github.com/chris-rock/node-crypto-examples/blob/master/crypto-ctr.js
# Nodejs encryption with CTR
