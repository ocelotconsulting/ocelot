module.exports =
    preflight: (req) ->
        req.headers.origin and req.headers['access-control-request-method'] and req.method is 'OPTIONS'
    setCorsHeaders: (req, res) ->
        {origin} = req.headers
        headers = req.headers['access-control-request-headers']
        method = req.headers['access-control-request-method']

        if origin? # apparently an empty string is valid here
            res.setHeader 'Access-Control-Allow-Origin', origin or '*'
            res.setHeader 'Access-Control-Max-Age', '1728000'
            res.setHeader 'Access-Control-Allow-Credentials', 'true'
        if headers then res.setHeader 'Access-Control-Allow-Headers', headers
        if method then res.setHeader 'Access-Control-Allow-Methods', method