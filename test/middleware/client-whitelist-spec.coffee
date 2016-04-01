rewrite = require '../../src/rewrite'
response = require '../../src/response'
clientWhitelist = require '../../src/middleware/client-whitelist'
sinon = require 'sinon'
chai = require 'chai'
expect = chai.expect

sandbox = sinon.sandbox.create()

describe 'client whitelist middleware', ->
  beforeEach ->
    sandbox.restore()

  describe 'passes when', ->

      it 'there is no auth client id', ->
        route =
          'client-whitelist': ['abc']
        req =
          _route: route
        res = {}
        next = sandbox.stub()

        clientWhitelist req, res, next

        expect(next.called).to.be.true

      it 'there is no whitelist defined', ->
        route =
          'client-whitelist': []
        req =
          _auth: {client_id: 'abc'}
          _route: route
        res = {}
        next = sandbox.stub()

        clientWhitelist req, res, next

        expect(next.called).to.be.true

      it 'whitelist contains client id', ->
        route =
          'client-whitelist': ['abc']
        req =
          _auth: {client_id: 'abc'}
          _route: route
        res = {}
        next = sandbox.stub()

        clientWhitelist req, res, next
        expect(next.called).to.be.true

    describe 'fails when', ->

      it 'whitelist nonempty but doesnt contain known client id', ->
        route =
          'client-whitelist': ['abc']
        req =
          _auth: {client_id: 'xyz'}
          _route: route
        res = {}
        next = sandbox.stub()

        responseStub = sandbox.stub(response, 'send')

        clientWhitelist req, res, next

        expect(next.called).to.be.false
        responseStub.calledWith(res, 403, 'Client Unauthorized')
