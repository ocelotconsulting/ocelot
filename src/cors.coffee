config = require 'config'

domains = config.get('cors-domains')

endsWith = (str, suffix) ->
    str.indexOf(suffix, str.length - suffix.length) != -1

whitelistedDomain = (origin) ->
    domains? and origin? and domains.filter((domain) -> endsWith(origin, ".#{domain}")).length > 0 or domains.indexOf(origin) > -1

module.exports =
    preflight: (req) ->
        req.headers.origin and req.headers['access-control-request-method'] and req.method is 'OPTIONS'
    setCorsHeaders: (req, res) ->
        {origin} = req.headers
        headers = req.headers['access-control-request-headers']
        method = req.headers['access-control-request-method']

        if whitelistedDomain origin
            res.setHeader 'Access-Control-Allow-Origin', origin
            res.setHeader 'Access-Control-Max-Age', '1728000'
            res.setHeader 'Access-Control-Allow-Credentials', 'true'
        if headers then res.setHeader 'Access-Control-Allow-Headers', headers
        if method then res.setHeader 'Access-Control-Allow-Methods', method
