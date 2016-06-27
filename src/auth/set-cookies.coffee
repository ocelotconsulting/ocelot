crypt = require './crypt'
log = require '../log'

createCookies = (auth, route) ->
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
    if auth.refresh_token then refreshTokenCookie()
  ].filter((cookie) -> if cookie then true)
  .map((cookie) -> "#{cookie}; path=#{cookiePath}")
  .map((item) -> if route['cookie-domain'] then "#{item}; domain=#{route['cookie-domain']}" else item)

module.exports =
  setAuthCookies: (res, route, authentication) ->
    Promise.resolve()
    .then ->
        res.setHeader 'Set-Cookie', createCookies(authentication, route)
