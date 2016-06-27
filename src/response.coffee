send = (res, statusCode, text) ->
    res.setHeader 'server', 'ocelot'
    res.statusCode = statusCode
    if text
        res.write text
    res.end()
    if res._ws
      res._ws.destroy()

module.exports =
    send: send

    sendJSON: (res, statusCode, json) ->
        res.setHeader('Content-Type', 'application/json')
        send(res, statusCode, JSON.stringify(json))
