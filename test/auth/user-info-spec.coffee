userInfo = require '../../src/auth/user-info'
chai = require 'chai'
chaiAsPromised = require 'chai-as-promised'
chai.use chaiAsPromised
cache = require 'memory-cache'
sinon = require 'sinon'
agent = require('../../src/http-agent')

sandbox = sinon.sandbox.create()


describe 'user info', ->

  beforeEach ->
    sandbox.stub(cache, 'get').withArgs('user-info_abc').returns({token: "token123"})
    sandbox.stub(cache, 'put')

  afterEach ->
    sandbox.restore()

  describe 'resolves to empty', ->
    it 'when route has no scope', ->
      userInfo.getUserInfo('abc', {}).should.eventually.not.exist

    it 'when the scope does not contain openid', ->
      userInfo.getUserInfo('abc', {}).should.eventually.not.exist

    it 'when no json body returned', ->
      agentStub = {}
      agentStub.get = sandbox.stub().withArgs('abc').returns(agentStub)
      agentStub.set = sandbox.stub().withArgs('Authorization', 'Bearer def').returns(agentStub)
      agentStub.then = (func) -> func({text: "hi there"})

      sandbox.stub(agent, 'getAgent').returns(agentStub)

      #agent.getAgent().get(url).set('Authorization', 'Bearer ' + token)
      userInfo.getUserInfo('def', {scope: "123 openid 456"}).should.eventually.not.exist

    it 'when 403 status code returned', ->
      agentStub = {}
      agentStub.get = sandbox.stub().withArgs('abc').returns(agentStub)
      agentStub.set = sandbox.stub().withArgs('Authorization', 'Bearer def').returns(agentStub)
      agentStub.then = (passFunc, failFunc) -> failFunc({response: {statusCode: 403}})

      sandbox.stub(agent, 'getAgent').returns(agentStub)

      #agent.getAgent().get(url).set('Authorization', 'Bearer ' + token)
      userInfo.getUserInfo('def', {scope: "123 openid 456"}).should.eventually.not.exist

    it 'when any other status code', ->
      agentStub = {}
      agentStub.get = sandbox.stub().withArgs('abc').returns(agentStub)
      agentStub.set = sandbox.stub().withArgs('Authorization', 'Bearer def').returns(agentStub)
      agentStub.then = (passFunc, failFunc) -> failFunc({response: {statusCode: 403}})

      sandbox.stub(agent, 'getAgent').returns(agentStub)

      #agent.getAgent().get(url).set('Authorization', 'Bearer ' + token)
      userInfo.getUserInfo('def', {scope: "123 openid 456"}).should.eventually.not.exist

  describe 'resolves user info', ->
    it 'when token found in cache', ->
      userInfo.getUserInfo('abc', {scope: "123 openid 456"}).should.eventually.eql({token: "token123"})

    it 'when agent resolves url', ->
      agentStub = {}
      agentStub.get = sandbox.stub().withArgs('abc').returns(agentStub)
      agentStub.set = sandbox.stub().withArgs('Authorization', 'Bearer def').returns(agentStub)
      agentStub.then = (func) -> func({body: {token: "token1234"}})

      sandbox.stub(agent, 'getAgent').returns(agentStub)

      #agent.getAgent().get(url).set('Authorization', 'Bearer ' + token)
      userInfo.getUserInfo('def', {scope: "123 openid 456"}).should.eventually.eql({token: "token1234"})
