var https = require('https'),
    Promise = require('promise'),
    url = require('url');

exports.code = function(reqUrl) {
    return new Promise(function(resolve, reject) {

        var url_parts = url.parse(reqUrl, true);
        var query = url_parts.query;
        var code = query.code;
        var state = query.state;

        var pingRedirect = new Buffer(state, 'base64').toString('utf8');
        if(pingRedirect.indexOf('?') > -1) {
            pingRedirect = pingRedirect.substring(pingRedirect.indexOf('?'));
        }
        pingRedirect = pingRedirect + "/receive-auth-token";
        pingRedirect=encodeURIComponent(pingRedirect);

        console.log("redirect 2: " + pingRedirect);

        var payload = 'grant_type=authorization_code&code=' + code + '&redirect_uri=' + pingRedirect;
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
        var post_req = https.request(options, function(postres) {
            var data = '';
            postres.setEncoding('utf8');

            postres.on('data', function(chunk) {
                data = data + chunk;
            });

            postres.on('end', function() {
                var result = JSON.parse(data);
                resolve(result);
            });

            postres.on('error', function(error) {
                console.log(error);
                reject(error);
            });
        });

        // post the data
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
