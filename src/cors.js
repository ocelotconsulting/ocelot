exports.preflight = function (req) {
    return typeof req.headers.origin !== 'undefined' && req.method === 'OPTIONS';
};

exports.setCorsHeaders = function (req, res) {
    var origin = req.headers.origin;
    var headers = req.headers['access-control-req-headers'];
    var method = req.headers['access-control-req-method'];

    if (typeof origin !== 'undefined') {
        res.setHeader('Access-Control-Allow-Origin', origin || '*');
        res.setHeader('Access-Control-Max-Age', '1728000');
        res.setHeader('Access-Control-Allow-Credentials', 'true');
    }

    if (headers)
        res.setHeader('Access-Control-Allow-Headers', headers);

    if (method)
        res.setHeader('Access-Control-Allow-Methods', method);
};