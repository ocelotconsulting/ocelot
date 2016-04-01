poweredByMiddleware = require '../../src/middleware/poweredby'
sinon = require 'sinon'
chai = require 'chai'
expect = chai.expect

sandbox = sinon.sandbox.create()

describe 'poweredby middleware', ->
  afterEach ->
    sandbox.restore()

  it 'adds the power of ocelot', ->
    route =
      route: 'my.route'
    req =
      url: "/abc"
      _route: route
    res = {setHeader: sandbox.stub()}

    next = sandbox.stub()

    poweredByMiddleware(req,res,next)
    expect(res.setHeader.calledWith('powered-by', 'ocelot')).to.be.true
    expect(next.called).to.be.true
