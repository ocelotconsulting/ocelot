module.exports =
    request: (px, req, res, url) ->
        req.url = url.path
        if req._ws
          px.ws req, req._ws, req._head, target: "#{url.protocol}//#{url.host}"
        else
          px.web req, res, target: "#{url.protocol}//#{url.host}"
