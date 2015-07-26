var props = require('deep-property'),
    poster = require('./poster'),
    https = require('https');

exports.token = function (req, route) {
    return new Promise(function (resolve, reject) {

        var token = parseCookies(req)[props.get(route, 'authentication.cookie-name') + '_RT'];
        var payload = 'grant_type=refresh_token&refresh_token=' + token;
        var basicAuth = 'basic VFBTX1RFU1Q6VFBTX1RFU1Q=';

        var options = {
            host: 'test.amp.monsanto.com',
            path: '/as/token.oauth2?' + payload,
            method: 'POST',
            headers: {
                Authorization: basicAuth
            }
        };

        // Set up the request
        var post_req = https.request(options, function (res) {
            var data = '';
            res.setEncoding('utf8');

            res.on('data', function (chunk) {
                data = data + chunk;
            });

            res.on('end', function () {
                var result = JSON.parse(data);
                resolve(result);
            });

            res.on('error', function (error) {
                console.log(error);
                reject(error);
            });
        });

        // post the data
        post_req.write(payload);
        post_req.end();
    });
};

function parseCookies(req) {
    var list = {},
        rc = req.headers.cookie;

    rc && rc.split(';').forEach(function(cookie) {
        var parts = cookie.split('=');
        list[parts.shift().trim()] = decodeURI(parts.join('='));
    });

    return list;
}



// https://test.amp.monsanto.com/as/token.oauth2?grant_type=refresh_token&client_id=TPS_TEST&client_secret=TPS_TEST&refresh_token=H6nV4JHmhq3Zem0XLeEByEgXx824AUUZsGUecTZoTO