var https = require('https'),
    props = require('deep-property'),
    url = require('url'),
    config = require('config');

function doPost(query, client, secret) {
    return new Promise(function(resolve, reject) {
        var basicAuth = 'basic ' + new Buffer(client + ':' + secret, 'utf8').toString('base64');
        var authServer = url.parse(config.get('authentication.ping.host'));

        var options = {
            host: authServer.host,
            path: '/as/token.oauth2?' + query,
            method: 'POST',
            headers: {
                Authorization: basicAuth
            }
        };

        var httpsReq = https.request(options, function (postres) {
            var data = '';
            postres.setEncoding('utf8');

            postres.on('data', function (chunk) {
                data = data + chunk;
            });

            postres.on('end', function () {
                var result = JSON.parse(data);
                if (!result.error) {
                    resolve(result);
                }
                else {
                    console.log(result.error);
                    reject(result.error);
                }
            });
        });
        httpsReq.on('error', function (error) {
            console.log(error);
            reject(error);
        });
        httpsReq.end();
    });
}

exports.post = doPost;

exports.post = function (query, route) {
    var client = route['client-id'];
    var secret = route['client-secret'];

    return doPost(query, client, secret);
};

exports.postAs = function (query, client, secret) {
    return doPost(query, client, secret);
};