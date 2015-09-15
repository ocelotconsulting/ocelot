module.exports =
    parse: (req) ->
        list = {}
        req.headers.cookie and req.headers.cookie.split(';').forEach((cookie) ->
            parts = cookie.split('=')
            list[parts.shift().trim()] = decodeURI(parts.join('='))
        )
        list