internalize = require '../../src/middleware/internalize'
chai = require 'chai'
expect = chai.expect
sinon = require 'sinon'

sandbox = sinon.sandbox.create()

describe 'internalize middlware', ->

  afterEach ->
    sandbox.restore()

  it 'sets the requests internal property', ->
    req = {}
    res = {}
    next = sinon.stub()

    internalize(req, res, next)

    expect(req._internal).to.be.true
    expect(next.called).to.be.true
