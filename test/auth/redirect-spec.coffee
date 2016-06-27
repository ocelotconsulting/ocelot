assert = require('assert')
sinon = require('sinon')
headers = require('../../src/auth/headers')
redirect = require('../../src/auth/redirect')
response = require('../../src/response')
responseMock = undefined

restore = (mockFunc) ->
  if mockFunc and mockFunc.restore
    mockFunc.restore()

describe 'redirect', ->
  it 'can redirect current page for refresh', ->
    req =
      headers: host: 'myhost/'
      url: 'my/url'
    res = {}
    setHeader = sinon.spy()
    setHeader.withArgs 'Location', 'http://myhost/my/url'
    res.setHeader = setHeader
    responseMock = sinon.mock(response, 'send')
    responseMock.expects('send').withArgs(res, 307).once()
    redirect.refreshPage req, res
    assert.equal setHeader.withArgs('Location', 'http://myhost/my/url').calledOnce, true
    responseMock.verify()

  it 'can redirect to oauth server', ->
    req =
      headers: host: 'myhost/'
      url: 'my/url'
      protocol: 'http:'
    res = {}
    route = {}
    route['client-id'] = 'abc123'
    setHeader = sinon.spy()
    setHeader.withArgs 'Location', 'http://myhost/my/url'
    res.setHeader = setHeader
    responseMock = sinon.mock(response, 'send')
    responseMock.expects('send').withArgs(res, 307).once()
    redirect.startAuthCode req, res, route
    expectedUrl = 'https://testy.local/as/authorization.oauth2?response_type=code&client_id=abc123&redirect_uri=http%3A%2F%2Fmyhost%2Fmy%2Furl%2Freceive-auth-token&state=aHR0cDovL215aG9zdC9teS91cmw%3D'
    assert.equal setHeader.withArgs('Location', expectedUrl).calledOnce, true
    responseMock.verify()

  afterEach ->
    restore responseMock
