assert = require 'assert'
sinon = require 'sinon'
require 'sinon-as-promised'
headers = require '../../src/auth/headers'
postman = require '../../src/auth/postman'
exchange = require '../../src/auth/exchange'
oauth = require '../../src/auth/oauth'
chai = require 'chai'
expect = chai.expect

describe 'oauth', ->
  {postmanMock} = {}

  beforeEach ->
    postmanMock = sinon.stub postman, 'postAs'

  afterEach ->
    postmanMock.restore()

  it 'validates token', (done) ->
    auth = id: 'myauth'
    postmanMock.resolves auth
    oauth.validate("abc").then ((returnedAuth) ->
      assert.equal auth, returnedAuth
      done()
    ), done

  it 'caches validations', (done) ->
    auth = id: 'myauth'
    postmanMock.resolves auth
    oauth.validate("abc").then =>
      oauth.validate("abc").then =>
        assert.equal (postmanMock.callCount < 2), true
        done()
    .catch done

  it 'gets bearer by alt-auth before authorization header', ->
    req =
      headers:
        authorization: 'bearer something'
        'alt-auth': 'bearer realtoken'


    oauth.getToken(req).then (token) ->
      expect(token).to.equal 'realtoken'

  it 'gets bearer by authorization header before cookie', ->
    req =
      headers:
        authorization: 'bearer something'
    route =
      'cookie-name': 'cookie1'
    cookies =
      cookie1: 'cookievalue'

    oauth.getToken(req).then (token) ->
      expect(token).to.equal 'something'

  it 'gets bearer by cookie', ->
    req =
      headers:
        blah: 'bleh'
    route =
      'cookie-name': 'cookie1'
    cookies =
      cookie1: 'cookievalue'

    oauth.getToken(req, route, cookies).then (token) ->
      expect(token).to.equal 'cookievalue'
