var Promise = require('promise');

exports.request = function(proxy, req, res, url) {
  req.url = url.path;

  proxy.web(req, res, {
    target: url.protocol + "//" + url.host
  });

  proxy.on('error', function(e) {
    console.log(url.href + ": " +  e.toString());
  });
};
