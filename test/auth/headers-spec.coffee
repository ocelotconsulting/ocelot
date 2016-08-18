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

describe 'auth headers', ->
    it 'adds client header if one exists on the validation payload', ->
        req =
          headers:
            cookie: 'this=that'
          _auth:
            client_id: 'some-app'
          _route:
            'client-header': 'client-id'

        headers.addAuth req
        assert.equal req.headers['client-id'], 'some-app'

    it 'omits client header if missing from authorization', ->
        req =
          headers:
            cookie: 'this=that'
          _auth: {}
          _route:
            'client-header': 'client-id'

        headers.addAuth req
        assert.equal !req.headers['client-id'], true

    it 'unsets request headers if collides with client or user id headers', ->
        req =
            headers:
              myclient: 'my_client'
              myuser: 'my_user'
              cookie: 'this=that'
              auth: {}
            _route:
              'client-header': 'myclient'
              'user-header': 'myuser'

        headers.addAuth req
        assert(not req.headers.hasOwnProperty headerName) for headerName in ['myclient', 'myuser']

describe 'custom headers', ->
    it 'adds custom headers specified in the route information', ->
        req =
          headers:
            cookie: 'this=that'
          _route:
            'custom-headers': [{'X-custom': 'X-header'}, {'X-another': 'X-header'}]
        headers.addCustomHeaders req
        for {key, value} in req._route['custom-headers']
            assert.equal req.headers[key], value

    it 'does not break if custom headers do not exist', ->
        req =
          headers: {}
          _route: {}
        headers.addCustomHeaders req
        assert.equal true, true
