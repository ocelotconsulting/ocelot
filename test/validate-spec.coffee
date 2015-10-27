assert = require 'assert'
sinon = require 'sinon'
require 'sinon-as-promised'
headers = require '../src/auth/headers'
postman = require '../src/auth/postman'
exchange = require '../src/auth/exchange'
validate = require '../src/auth/validate'

describe 'validate', ->
    {postmanMock} = {}

    beforeEach ->
        postmanMock = sinon.stub postman, 'postAs'

    afterEach ->
        postmanMock.restore()

    it 'resolves if no required validation', (done) ->
        req = {}
        route = {}
        route['require-auth'] = false
        validate.authentication(req, route).then ((auth) ->
            done()
        ), (auth) ->
            assert.fail 'auth failed!'
            done()

    it 'rejects if required validation but none sent', (done) ->
        req = headers: ''
        route = {}
        validate.authentication(req, route).then ((auth) ->
            assert.fail 'should have failed!'
            done()
        ), (auth) ->
            done()

    it 'resolves if bearer token found and valid', (done) ->
        req = headers: {}
        route = {}
        auth = id: 'myauth'
        req.headers.authorization = 'bearer abc'
        postmanMock.resolves auth
        validate.authentication(req, route).then ((returnedAuth) ->
            assert.equal auth, returnedAuth
            done()
        ), (auth) ->
            assert.fail 'failed!'
            done()
    it 'resolves if auth token found and valid', (done) ->
        req = headers: cookie: 'mycookie=abcd'
        route = {}
        auth = id: 'myauth'
        route['cookie-name'] = 'mycookie'
        postmanMock.resolves auth
        validate.authentication(req, route).then ((returnedAuth) ->
            assert.equal auth, returnedAuth
            done()
        ), (auth) ->
            assert.fail 'failed!'
            done()
    it 'rejects if auth token found but invalid', (done) ->
        req = headers: cookie: 'mycookie=abcde'
        route = {}
        auth = id: 'myauth'
        route['cookie-name'] = 'mycookie'
        postmanMock.rejects 'you suck'
        validate.authentication(req, route).then ((auth) ->
            assert.fail 'should fail!'
            done()
        ), (auth) ->
            done()
    it 'caches validations', (done) ->
        req = headers: cookie: 'mycookie=abcdef'
        route = {}
        auth = id: 'myauth'
        route['cookie-name'] = 'mycookie'
        postmanMock.resolves auth
        validate.authentication(req, route)
        .then (auth) -> validate.authentication(req, route)
        .then (auth) ->
          assert.equal postmanMock.calledOnce, true
          done()
        .catch  ->
          assert.fail 'failed!'
          done()


