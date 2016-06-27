rewrite = require '../../src/rewrite'
response = require '../../src/response'
backendHost = require '../../src/middleware/backend-host'
sinon = require 'sinon'
chai = require 'chai'
expect = chai.expect

sandbox = sinon.sandbox.create()

describe 'backend host middleware', ->
  afterEach ->
    sandbox.restore()

  it 'sends a 404 if route cannot be mapped', ->
    route =
      route: 'my.route'
    req =
      url: "/abc"
      _route: route
    res = {}

    next = sandbox.stub()
    sandbox.stub(rewrite, "mapRoute").withArgs('/abc', {route: 'my.route'}).returns null
    responseStub = sandbox.stub(response, "send")

    backendHost(req,res,next)
    expect(responseStub.calledWith(res, 404, 'No active URL for route')).to.be.true
    expect(next.called).to.be.false

  it 'sets route url and calls next if backend url can be determined', ->
    route =
      route: 'my.route'
    req =
      url: "/abc"
      _route: route
    res = {}

    next = sandbox.stub()
    sandbox.stub(rewrite, "mapRoute").withArgs('/abc', route).returns("my.url/abc")
    responseStub = sandbox.stub(response, "send")

    backendHost(req,res,next)

    expect(responseStub.called).to.be.false
    expect(next.called).to.be.true
