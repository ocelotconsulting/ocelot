profile = require '../../src/auth/profile'
chai = require 'chai'
chaiAsPromised = require 'chai-as-promised'
chai.use chaiAsPromised
cache = require 'memory-cache'
sinon = require 'sinon'
agent = require('../../src/http-agent')
config = require 'config'

sandbox = sinon.sandbox.create()

describe 'profile', ->

  beforeEach ->
    sandbox.stub(cache, 'get').withArgs('profile_abc').returns({firstName: "chris"})
    sandbox.stub(cache, 'put')

  afterEach ->
    sandbox.restore()

  describe 'resolves to empty', ->
    it 'when user profile is false', ->
      profile.getProfile({_auth: {token: 'xyz', access_token: {user_id: 'cjcoff'}}, _route: {'ent-app-id': 'myapp', 'user-profile-enabled': false}}, 'abc').should.eventually.not.exist

    it 'when authentication does not contain a user id', ->
      profile.getProfile({_auth: {}, _route: {'ent-app-id': 'myapp'}}, 'abc').should.eventually.not.exist

    it 'when profile info does not resolve', ->
      agentStub = {}
      agentStub.get = sandbox.stub().returns(agentStub)
      agentStub.set = sandbox.stub().withArgs('Authorization', 'Bearer def').returns(agentStub)
      agentStub.then = (success, fail) -> fail()

      sandbox.stub(agent, 'getAgent').returns(agentStub)
      profile.getProfile({_auth: {token: 'xyz', access_token: {user_id: 'cjcoff'}}, _route: {'ent-app-id': 'myapp', 'user-profile-enabled': true}}, 'def').should.eventually.eql {}

  describe 'resolves profile information', ->
    it 'when user id and profile url present and profile info resolves', ->
      agentStub = {}
      agentStub.get = sandbox.stub().returns(agentStub)
      agentStub.set = sandbox.stub().withArgs('Authorization', 'Bearer def').returns(agentStub)
      agentStub.then = (func) -> func({body: {firstName: "chris"}})

      sandbox.stub(agent, 'getAgent').returns(agentStub)

      sandbox.stub(config, 'get').withArgs('authentication.profile-endpoint').returns("http://some-profile-service")
      profile.getProfile({_auth: {token: 'xyzz', access_token: {user_id: 'cjcoff'}}, _route: {'ent-app-id': 'myapp', 'user-profile-enabled': true}}, 'def').should.eventually.eql({firstName: "chris"})

#    it 'when profile is found in cache', ->
#      profile.getProfile({_auth: {token: 'xyzz', access_token: {user_id: 'cjcoff'}}, _route: {'ent-app-id': 'myapp', 'user-profile-enabled': true}}, 'abc').should.eventually.eql({firstName: "chris"})
