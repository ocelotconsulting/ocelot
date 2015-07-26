var props = require('deep-property'),
  https = require('https'),
  Promise = require('promise');

exports.authentication = function(req, route) {
  return new Promise(function(resolve, reject) {
    if (props.get(route, 'authentication.disabled') === true) {
      resolve({
        required: false
      });
    }

    var token = null;
    var canRefresh = false;
    var requiresCookie = props.has(route, 'authentication.cookie-name');

    if (props.has(route, 'authentication.cookie-name')) {
      token = parseCookies(req)[props.get(route, 'authentication.cookie-name')];
    }
    if (props.has(route, 'authentication.cookie-name')) {
      if(parseCookies(req)[props.get(route, 'authentication.cookie-name') + '_RT']){
        canRefresh = true;
      }
    }

    if (props.has(req.headers['Authorization'])) {
      // matches 'Bearer <token>'
    }

    if(token == null){
      resolve({
        required: true,
        valid: false,
        refresh: canRefresh,
        redirect: requiresCookie
      });
    }

    var payload = 'grant_type=' + encodeURIComponent('urn:pingidentity.com:oauth2:grant_type:validate_bearer') + '&token=' + token;
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
    var post_req = https.request(options, function(res) {
      var data = '';
      res.setEncoding('utf8');

      res.on('data', function(chunk) {
        data = data + chunk;
      });

      res.on('end', function() {
        var result = JSON.parse(data);
        result.required = true;
        result.valid = true;
        resolve(result);
      });

      res.on('error', function(error) {
        console.log(error);
        reject({
          required: true,
          valid: false,
          error: error,
          refresh: canRefresh,
          redirect: requiresCookie
        });
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
