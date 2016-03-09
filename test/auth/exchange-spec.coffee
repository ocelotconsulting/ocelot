assert = require 'assert'
sinon = require 'sinon'
headers = require '../../src/auth/headers'
postman = require '../../src/auth/postman'
exchange = require '../../src/auth/exchange'

postmanMock = undefined
headerMock = undefined

restore = (mockFunc) ->
    if mockFunc and mockFunc.restore
        mockFunc.restore()
    return

formData =
    grant_type: 'authorization_code'
    code: 'abc'
    redirect_uri: 'test/receive-auth-token'

describe 'exchange', ->
    it 'returns 500 when exchange fails', ->
        req = url: 'http://host?state=dGVzdA%3D%3D&code=abc'
        res =
            end: ->
                @ended = true
            ended: false
            write: (text) ->
                @text = text
            setHeader: (header) ->

        route = {}
        postmanMock = sinon.stub(postman, 'post')

        postmanMock.withArgs(formData, route).returns then: (success, failure) ->
            failure 'error message'

        exchange.authCodeFlow req, res, route
        assert.equal res.statusCode, 500
        assert.equal res.ended, true
        assert.equal res.text, 'error message'

    it 'exchanges code for token, sets token cookie', ->
        req = url: 'http://host?state=dGVzdA%3D%3D&code=abc'
        res =
            end: ->
                @ended = true
            ended: false
            setHeader: (name, value) ->
                @headers[@headers.length] =
                    name: name
                    value: value
            headers: []
        route = {}
        payload = id: 'payload'
        postmanMock = sinon.stub(postman, 'post')
        postmanMock.withArgs(formData, route).returns then: (success, failure) ->
            success payload
        headerMock = sinon.stub(headers, 'setAuthCookies')
        headerMock.withArgs(res, route, payload).returns then: (s, f) ->
            s res
        exchange.authCodeFlow req, res, route
        assert.equal res.statusCode, 307
        assert.equal res.ended, true
        assert.equal res.headers.length, 2
        assert.equal res.headers[0].name, 'Location'
        assert.equal res.headers[0].value, 'test'
        assert.equal res.headers[1].name, 'server'
        assert.equal res.headers[1].value, 'ocelot'

    afterEach ->
        restore postmanMock
        restore headerMock
