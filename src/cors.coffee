config = require 'config'
URL = require 'url'
originPortRegex = /(.*):\d+$/

domains = config.get('cors-domains')

endsWith = (str, suffix) ->
    str.indexOf(suffix, str.length - suffix.length) != -1

isTrustedOrigin = (origin, referer) ->
    isWhitelisted = (origin) ->
        if originPortRegex.test origin
            origin = originPortRegex.exec(origin)[1]
        domains.filter((domain) -> endsWith(origin, ".#{domain}")).length > 0 or
          domains.indexOf(origin) > -1

    isRefererWhitelisted = () ->
        if referer?
            url = URL.parse(referer).host
            url and isWhitelisted(URL.parse(referer).host)
        else
            false

    isWhitelisted(origin) or origin == 'null' and isRefererWhitelisted()


module.exports =
    shortCircuit: (req) ->
        {origin, referer} = req.headers

        isCorsRequest = -> origin?
        isPreflightRequest = -> req.headers['access-control-request-method'] and req.method is 'OPTIONS'

        isCorsRequest() and (isPreflightRequest() or not isTrustedOrigin(origin, referer))

    setCorsHeaders: (req, res) ->
        {origin, referer} = req.headers
        isCorsRequest = -> origin?

        headers = req.headers['access-control-request-headers']
        method = req.headers['access-control-request-method']

        if isCorsRequest() and isTrustedOrigin(origin, referer)
            res.setHeader 'Access-Control-Allow-Origin', origin
            res.setHeader 'Access-Control-Max-Age', '1728000'
            res.setHeader 'Access-Control-Allow-Credentials', 'true'
        if headers then res.setHeader 'Access-Control-Allow-Headers', headers
        if method then res.setHeader 'Access-Control-Allow-Methods', method
