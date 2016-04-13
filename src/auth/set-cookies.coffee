crypt = require './crypt'
wam = require '../backend/wam'
log = require '../log'

createCookies = (wamResult, auth, route) ->
  cookieName = route['cookie-name']
  cookiePath =
      if route['cookie-path']
          route['cookie-path']
      else if route.route.indexOf("/") != -1
          route.route.substring(route.route.indexOf("/"))
      else
          "/"

  refreshTokenCookie = ->
      "#{cookieName}_rt=#{crypt.encrypt(auth.refresh_token, route['client-secret'])};HttpOnly"

  [
    "#{cookieName}=#{auth.access_token}"
    if wamResult then "AXMSESSION=#{wamResult}"
    if auth.refresh_token then refreshTokenCookie()
  ].filter((cookie) -> if cookie then true)
  .map((cookie) -> "#{cookie}; path=#{cookiePath}")
  .map((item) -> if route['cookie-domain'] then "#{item}; domain=#{route['cookie-domain']}" else item)

module.exports =
  setAuthCookies: (res, route, authentication) ->
    Promise.resolve()
    .then ->
      if route['wam-legacy'] then wam.getWAMToken authentication.access_token
    .then (wamResult) ->
        res.setHeader 'Set-Cookie', createCookies(wamResult, authentication, route)
