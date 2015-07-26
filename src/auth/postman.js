var https = require('https'),
    props = require('deep-property');

exports.post = function (query, route) {
    var client = props.get(route, 'authentication.client-id');
    var secret = props.get(route, 'authentication.client-secret');

    return new Promise(function(resolve, reject) {
        var basicAuth = 'basic ' + new Buffer(client + ':' + secret, 'utf8').toString('base64');

        var options = {
            host: 'test.amp.monsanto.com',
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
            resolve(error);
        });
        httpsReq.end();
    });
};