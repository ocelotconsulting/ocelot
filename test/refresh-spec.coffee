assert = require('assert')
sinon = require('sinon')
postman = require('../src/auth/postman')
redirect = require('../src/auth/redirect')
headers = require('../src/auth/headers')
refresh = require('../src/auth/refresh')
crypt = require('../src/auth/crypt')
postmanMock = undefined
headersMock = undefined
redirectMock = undefined

restore = (mockFunc) ->
    if mockFunc and mockFunc.restore
        mockFunc.restore()

describe 'refresh', ->
    it 'refreshes if post is successful', ->
        secret = 'secret'
        unencrypted_refresh = 'abc'
        req = headers: cookie: 'something_rt=' + crypt.encrypt(unencrypted_refresh, secret)
        res = id: 'res'
        route = id: 'route'
        auth = id: 'auth'
        route['cookie-name'] = 'something'
        route['client-secret'] = secret
        postmanMock = sinon.stub(postman, 'post')

        postData =
            grant_type: 'refresh_token'
            refresh_token: unencrypted_refresh

        postmanMock.withArgs(postData, route).returns then: (s, f) ->
            s auth

        headerMock = sinon.stub(headers, 'setAuthCookies')
        headerMock.withArgs(res, route, auth).returns then: (s, f) ->
            s res

        redirectMock = sinon.stub(redirect, 'refreshPage');
        redirectMock.withArgs(req, res);
        refresh.token req, res, route
        assert postmanMock.calledOnce == true
        assert redirectMock.calledOnce == true

    it 'redirects if post is unsuccessful', ->
        secret = 'secret'
        unencrypted_refresh = 'abc'
        req = headers: cookie: 'something_rt=' + crypt.encrypt(unencrypted_refresh, secret)
        res = id: 'res'
        route = id: 'route'
        auth = id: 'auth'
        route['cookie-name'] = 'something'
        route['client-secret'] = secret
        postmanMock = sinon.stub(postman, 'post')

        postData =
            grant_type: 'refresh_token'
            refresh_token: unencrypted_refresh

        postmanMock.withArgs(postData, route).returns then: (s, f) ->
            f auth

        redirectMock = sinon.stub(redirect, 'startAuthCode')
        redirectMock.withArgs req, res, route
        refresh.token req, res, route
        assert postmanMock.calledOnce == true
        assert redirectMock.calledOnce == true

    afterEach ->
        restore postmanMock
        restore headersMock
        restore redirectMock