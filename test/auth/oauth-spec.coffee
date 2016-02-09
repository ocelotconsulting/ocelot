assert = require 'assert'
sinon = require 'sinon'
require 'sinon-as-promised'
headers = require '../../src/auth/headers'
postman = require '../../src/auth/postman'
exchange = require '../../src/auth/exchange'
oauth = require '../../src/auth/oauth'

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



