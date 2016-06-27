internalFilter = require '../../src/middleware/internal-filter'
response = require '../../src/response'

chai = require 'chai'
expect = chai.expect
sinon = require 'sinon'

sandbox = sinon.sandbox.create()

describe 'internal filter middlware', ->

  afterEach ->
    sandbox.restore()

  it 'allows internal requests for internal routes', ->

    req = {_internal: true, _route: {internal: true}}
    res = {}
    next = sinon.stub()

    internalFilter(req, res, next)

    expect(next.called).to.be.true

  it 'gives 403 if internal route accessed externally', ->

    req = {_internal: false, _route: {internal: true}}
    res = {}
    next = sinon.stub()

    stubby = sandbox.stub(response, 'send')

    internalFilter(req, res, next)

    expect(next.called).to.be.false
    expect(stubby.calledWith(res, 403, 'Route is not public')).to.be.true
