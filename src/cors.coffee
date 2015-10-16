module.exports =
    preflight: (req) ->
        req.headers.origin and req.headers['access-control-request-method'] and req.method == 'OPTIONS'
    setCorsHeaders: (req, res) ->
        origin = req.headers.origin
        headers = req.headers['access-control-request-headers']
        method = req.headers['access-control-request-method']
        if typeof origin != 'undefined'
            res.setHeader 'Access-Control-Allow-Origin', origin or '*'
            res.setHeader 'Access-Control-Max-Age', '1728000'
            res.setHeader 'Access-Control-Allow-Credentials', 'true'
        if headers
            res.setHeader 'Access-Control-Allow-Headers', headers
        if method
            res.setHeader 'Access-Control-Allow-Methods', method