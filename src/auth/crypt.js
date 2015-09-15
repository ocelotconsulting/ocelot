// Adapted from https://github.com/chris-rock/node-crypto-examples/blob/master/crypto-ctr.js

// Nodejs encryption with CTR
var crypto = require('crypto'),
    algorithm = 'aes-256-ctr';

exports.encrypt = function (text, secret){
    var cipher = crypto.createCipher(algorithm, secret.toString('binary'))
    var crypted = cipher.update(text,'utf8','hex')
    crypted += cipher.final('hex');
    return crypted;
}

exports.decrypt = function (text, secret){
    var decipher = crypto.createDecipher(algorithm, secret.toString('binary'))
    var dec = decipher.update(text,'hex','utf8')
    dec += decipher.final('utf8');
    return dec;
}