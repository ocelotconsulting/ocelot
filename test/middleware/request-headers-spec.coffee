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

    next = sandbox.stub()

    requestHeaderMiddleware(req,res,next)

    expect(addAuthStub.calledWith(req, req._route, req._auth, req.cookies)).to.be.true
    expect(addCustomStub.calledWith(req, req._route)).to.be.true
    expect(next.called).to.be.true
