assert = require('assert')
headers = require('../../src/auth/headers')
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

describe 'headers', ->
    it 'returns tokens with path equal to route key', ->
        res.setHeader = (name, value) ->
            @[name] = value

        route['cookie-name'] = 'mycookie'
        route['route'] = 'domain/abc'
        route['client-secret'] = 'secret'
        authentication['refresh_token'] = 'abc123'
        authentication['access_token'] = 'def123'
        authentication['id_token'] = 'ghi123'
        headers.setAuthCookies res, route, authentication
        .then ->
            assert.equal res['Set-Cookie'].indexOf('mycookie=def123; path=/abc') > -1, true
            assert.equal res['Set-Cookie'].indexOf("mycookie_rt=#{crypt.encrypt(authentication.refresh_token, route['client-secret'])};HttpOnly; path=/abc") > -1, true
            assert.equal res['Set-Cookie'].indexOf('mycookie_oidc=ghi123; path=/abc') > -1, true

    it 'omit refresh or oidc token when not present', ->

        res.setHeader = (name, value) ->
            @[name] = value

        route['cookie-name'] = 'mycookie'
        route.route = 'domain/abc'
        authentication['access_token'] = 'def123'
        headers.setAuthCookies res, route, authentication
        .then ->
            assert.equal res['Set-Cookie'].indexOf('mycookie=def123; path=/abc') > -1, true
            assert.equal res['Set-Cookie'].indexOf('mycookie_rt=abc123; path=/abc') > -1, false
            assert.equal res['Set-Cookie'].indexOf('mycookie_oidc=ghi123; path=/abc') > -1, false

    it 'overrides the route key if you have a cookie path on your route', ->

        res.setHeader = (name, value) ->
            @[name] = value

        route['cookie-name'] = 'mycookie'
        route['cookie-path'] = '/zzz'
        route['route'] = 'abc'
        route['client-secret'] = 'secret'
        authentication['refresh_token'] = 'abc123'
        authentication['access_token'] = 'def123'
        headers.setAuthCookies res, route, authentication
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
      headers.setAuthCookies res, route, authentication
      .then ->
          assert.equal res['Set-Cookie'].indexOf('mycookie=def123; path=/zzz; domain=xyz') > -1, true

describe 'auth headers', ->
    it 'adds user header if auth claims contains a subject', ->
        req = headers: {}
        req.headers.cookie = 'this=that'
        auth =
            client_id: 'some-app'
            claims:
                sub: 'cjcoff'
        route['user-header'] = 'user-id'
        route['cookie-name'] = 'my-cookie'
        req.headers['cookie'] = 'this=that;'
        headers.addAuth req, route, auth
        assert.equal req.headers['user-id'], 'cjcoff'

    it 'omits user header if oidc token missing', ->
        req = headers: {}
        req.headers.cookie = 'this=that'
        auth =
            client_id: 'some-app'
        route['user-header'] = 'user-id'
        route['cookie-name'] = 'my-cookie'
        req.headers['cookie'] = 'this=that;'
        headers.addAuth req, route, auth
        assert.equal !req.headers['user-id'], true

    it 'adds client header if one exists on the validation payload', ->
        req = headers: {}
        req.headers.cookie = 'this=that'
        auth =
            client_id: 'some-app'
        route['client-header'] = 'client-id'
        req.headers['cookie'] = 'this=that;'
        headers.addAuth req, route, auth
        assert.equal req.headers['client-id'], 'some-app'

    it 'omits client header if missing from authorization', ->
        req = headers: {}
        req.headers.cookie = 'this=that'
        auth = {}
        route['client-header'] = 'client-id'
        req.headers['cookie'] = 'this=that;'
        headers.addAuth req, route, auth
        assert.equal !req.headers['client-id'], true

    it 'unsets request headers if collides with client or user id headers', ->
        req = headers: {myclient: 'my_client', myuser: 'my_user'}
        req.headers.cookie = 'this=that'
        auth = {}
        route['client-header'] = 'myclient'
        route['user-header'] = 'myuser'
        req.headers['cookie'] = 'this=that;'
        headers.addAuth req, route, auth
        assert.equal req.headers['myclient'], undefined
        assert.equal req.headers['myuser'], undefined