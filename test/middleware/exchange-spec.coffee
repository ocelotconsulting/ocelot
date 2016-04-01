exchange = require '../../src/auth/exchange'
exchangeMiddleware = require '../../src/middleware/exchange'
sinon = require 'sinon'
chai = require 'chai'
expect = chai.expect

sandbox = sinon.sandbox.create()

describe 'exchange middleware', ->
  afterEach ->
    sandbox.restore()

  it 'completes request if oauth code exchange flow detected', ->
    route =
      route: 'my.route'
    req =
      url: "/abc"
      _route: route
    res = {}

    next = sandbox.stub()
    sandbox.stub(exchange, "accept").withArgs(req).returns true
    exchangeStub = sandbox.stub(exchange, "authCodeFlow")

    exchangeMiddleware(req,res,next)
    expect(exchangeStub.calledWith(req, res, route)).to.be.true
    expect(next.called).to.be.false

  it 'continues if no oauth code exchange detected', ->
    route =
      route: 'my.route'
    req =
      url: "/abc"
      _route: route
    res = {}

    next = sandbox.stub()
    sandbox.stub(exchange, "accept").withArgs(req).returns false
    exchangeStub = sandbox.stub(exchange, "authCodeFlow")

    exchangeMiddleware(req,res,next)
    expect(exchangeStub.called).to.be.false
    expect(next.called).to.be.true
