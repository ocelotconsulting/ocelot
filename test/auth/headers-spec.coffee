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

        assert(not req.headers.hasOwnProperty headerName) for headerName in ['myclient', 'myuser']

describe 'custom headers', ->
    it 'adds custom headers specified in the route information', ->
        req = headers: {}
        route['custom-headers'] = [{'X-custom': 'X-header'}, {'X-another': 'X-header'}]
        req.headers['cookie'] = 'this=that;'
        headers.addCustomHeaders req, route
        for {key, value} in route['custom-headers']
            assert.equal req.headers[key], value

    it 'doesnt break if custom headers doesnt exist', ->
        req = headers: {}
        headers.addCustomHeaders req, route
        assert.equal true, true
