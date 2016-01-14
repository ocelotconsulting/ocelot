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

    it 'resolves if no required auth', (done) ->
        req = {}
        route = {}
        route['require-auth'] = false
        validate.authentication(req, route).then ((auth) ->
            done()
        ), (auth) ->
            done('auth failed!')

    it 'rejects if required auth but none sent', (done) ->
        req = headers: ''
        route = {"require-auth": true}
        validate.authentication(req, route).then ((auth) ->
            done('should have failed!')
        ), (auth) ->
            done()

    it 'resolves if bearer token found and valid', (done) ->
        req = headers: {}
        route = {"require-auth": true}
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
        route = {"require-auth": true}
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
        route = {"require-auth": true}
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
        route = {"require-auth": true}
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


