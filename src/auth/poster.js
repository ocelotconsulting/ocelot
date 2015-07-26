var https = require('http');

exports.post = function (query, client, secret) {
    return new Promise(function (resolve, reject) {
        var basicAuth = 'basic VFBTX1RFU1Q6VFBTX1RFU1Q=';

        var options = {
            host: 'test.amp.monsanto.com',
            path: '/as/token.oauth2?' + query,
            method: 'POST',
            headers: {
                Authorization: basicAuth
            }
        };

        https.request(options, function (postres) {
            var data = '';
            postres.setEncoding('utf8');

            postres.on('data', function (chunk) {
                data = data + chunk;
            });

            postres.on('end', function () {
                var result = JSON.parse(data);
                resolve(result);
            });

            postres.on('error', function (error) {
                console.log(error);
                reject(error);
            });
        }).end();
    });
};