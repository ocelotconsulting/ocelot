module.exports =
    send: (res, statusCode, text) ->
        res.statusCode = statusCode
        if text then res.write text
        res.end()