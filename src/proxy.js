var Promise = require('promise');

exports.request = function(proxy, req, res, url) {
  req.url = url.pathname;

  proxy.web(req, res, {
    target: url.protocol + "//" + url.host
  });

  proxy.on('error', function(e) {
    // try moment
    console.log(new Date().toJSON().slice(0, 19) + "  Error running " + url.href + " " + JSON.stringify(e));
  });
}
