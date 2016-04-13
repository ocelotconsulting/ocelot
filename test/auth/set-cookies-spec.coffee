assert = require('assert')
setCookies = require('../../src/auth/set-cookies')
crypt = require('../../src/auth/crypt')
res = {}
route = {}
authentication = {}
auth = {}
beforeEach ->
    res = {}
    route = {}
    authentication = {}
    auth = {}

describe 'set cookies', ->
    it 'returns tokens with path equal to route key', ->
        res.setHeader = (name, value) ->
            @[name] = value

        route['cookie-name'] = 'mycookie'
        route['route'] = 'domain/abc'
        route['client-secret'] = 'secret'
        authentication['refresh_token'] = 'abc123'
        authentication['access_token'] = 'def123'
        authentication['id_token'] = 'ghi123'
        setCookies.setAuthCookies res, route, authentication
        .then ->
            assert.equal res['Set-Cookie'].indexOf('mycookie=def123; path=/abc') > -1, true
            assert.equal res['Set-Cookie'].indexOf("mycookie_rt=#{crypt.encrypt(authentication.refresh_token, route['client-secret'])};HttpOnly; path=/abc") > -1, true

    it 'overrides the route key if you have a cookie path on your route', ->

        res.setHeader = (name, value) ->
            @[name] = value

        route['cookie-name'] = 'mycookie'
        route['cookie-path'] = '/zzz'
        route['route'] = 'abc'
        route['client-secret'] = 'secret'
        authentication['refresh_token'] = 'abc123'
        authentication['access_token'] = 'def123'
        setCookies.setAuthCookies res, route, authentication
        .then ->
            assert.equal res['Set-Cookie'].indexOf('mycookie=def123; path=/zzz') > -1, true
            assert.equal res['Set-Cookie'].indexOf("mycookie_rt=#{crypt.encrypt(authentication.refresh_token, route['client-secret'])};HttpOnly; path=/zzz") > -1, true


    it 'allows you to set a cookie domain on your route', ->

      res.setHeader = (name, value) ->
          @[name] = value

      route['cookie-name'] = 'mycookie'
      route['cookie-path'] = '/zzz'
      route['cookie-domain'] = 'xyz'
      route['route'] = 'abc'
      route['client-secret'] = 'secret'
      authentication['refresh_token'] = 'abc123'
      authentication['access_token'] = 'def123'
      setCookies.setAuthCookies res, route, authentication
      .then ->
          assert.equal res['Set-Cookie'].indexOf('mycookie=def123; path=/zzz; domain=xyz') > -1, true
