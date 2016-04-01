prom = require '../../src/metrics/prometheus'
promMiddleware = require '../../src/middleware/prom'
sinon = require 'sinon'
chai = require 'chai'
expect = chai.expect

sandbox = sinon.sandbox.create()

describe 'prom middleware', ->
  afterEach ->
    sandbox.restore()

  it 'adds request processing metrics', ->
    route =
      route: 'my.route'
    req =
      url: "/abc"
      _route: route
    res = {on: () -> }

    promStub = sandbox.stub(prom, 'requestProcessing')
    next = sandbox.stub()

    promMiddleware(req,res,next)
    expect(promStub.calledWith(req)).to.be.true
    expect(next.called).to.be.true

  it 'adds response handlers for finish and close', ->
    route =
      route: 'my.route'
    req =
      url: "/abc"
      _route: route
    res = {on: sandbox.stub()}

    sandbox.stub(prom, 'requestProcessing')
    next = sandbox.stub()

    promMiddleware(req,res,next)
    expect(res.on.calledWith('finish')).to.be.true
    expect(res.on.calledWith('close')).to.be.true
    expect(next.called).to.be.true

  it 'does not add metrics if using websockets', ->
    route =
      route: 'my.route'
    req =
      url: "/abc"
      _route: route
      _ws: {}
    res = {on: sandbox.stub()}

    promStub = sandbox.stub(prom, 'requestProcessing')
    next = sandbox.stub()

    promMiddleware(req,res,next)
    expect(promStub.called).to.be.false
    expect(res.on.called).to.be.false
    expect(next.called).to.be.true
