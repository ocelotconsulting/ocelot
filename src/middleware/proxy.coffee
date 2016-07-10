httpProxy = require 'http-proxy'
response = require '../response'
proxy = require '../proxy'
log = require '../log'

px = httpProxy.createProxyServer {secure: false, changeOrigin: true, autoRewrite: true, ws: true}

px.on 'error', (err, req, res) ->
  response.send res, 500, 'Error during proxy: ' + err + ':' + err.stack

module.exports = (req, res, next) ->
  proxy.request px, req, res, req._url
