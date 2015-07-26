var Promise = require('promise');

exports.request = function(proxy, req, res, url) {
  req.url = url.pathname;

  proxy.web(req, res, {
    target: url.protocol + "//" + url.host
  });

  proxy.on('error', function(e) {
    // try moment
    res.statusCode = 500;
    res.write(e);
    res.end();
    return;
  });
};
