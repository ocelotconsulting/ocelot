cors = require '../../src/cors'
response = require '../../src/response'
corsMiddleWare = require '../../src/middleware/cors'
sinon = require 'sinon'
chai = require 'chai'
expect = chai.expect

sandbox = sinon.sandbox.create()

describe 'cors middleware', ->
  afterEach ->
    sandbox.restore()

  it 'sets headers and completes request if short circuit detected', ->
    route =
      route: 'my.route'
    req =
      url: "/abc"
    res = {}

    next = sandbox.stub()

    corsStub = sandbox.stub(cors, "setCorsHeaders")
    sandbox.stub(cors, "shortCircuit").withArgs(req).returns true
    responseStub = sandbox.stub(response, "send")

    corsMiddleWare(req,res,next)
    expect(corsStub.calledWith(req, res)).to.be.true
    expect(responseStub.calledWith(res, 204)).to.be.true
    expect(next.called).to.be.false

  it 'sets headers and continues if no short circuit detected', ->
    route =
      route: 'my.route'
    req =
      url: "/abc"
    res = {}

    next = sandbox.stub()

    corsStub = sandbox.stub(cors, "setCorsHeaders")
    sandbox.stub(cors, "shortCircuit").withArgs(req).returns false

    corsMiddleWare(req,res,next)
    expect(corsStub.calledWith(req, res)).to.be.true
    expect(next.called).to.be.true
