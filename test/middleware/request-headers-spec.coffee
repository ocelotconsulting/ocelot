headers = require '../../src/auth/headers'
requestHeaderMiddleware = require '../../src/middleware/request-headers'
sinon = require 'sinon'
chai = require 'chai'
expect = chai.expect

sandbox = sinon.sandbox.create()

describe 'request header middleware', ->
  afterEach ->
    sandbox.restore()

  it 'adds auth and custom http request headers', ->
    req =
      url: "/abc"
      _route: {route: 'my.route'}
      _auth: {some: "stuff"}
      cookies: {my: "cookie"}
    res = {}

    addAuthStub = sandbox.stub(headers, 'addAuth')
    addCustomStub = sandbox.stub(headers, 'addCustomHeaders')
    addProxyHeadersStub = sandbox.stub(headers, 'addProxyHeaders')

    next = sandbox.stub()

    requestHeaderMiddleware(req,res,next)

    expect(addAuthStub.calledWith(req)).to.be.true
    expect(addCustomStub.calledWith(req)).to.be.true
    expect(addProxyHeadersStub.calledWith(req)).to.be.true
    expect(next.called).to.be.true
