assert = require 'assert'
config = require 'config'
sinon = require 'sinon'
consul = require '../src/backend/consul.coffee'
redis = require '../src/backend/redis.coffee'
facade = require '../src/backend/facade.coffee'
describe 'facade', ->
  restore = (mockFunc) ->
    if mockFunc.restore
      mockFunc.restore()

  it 'initializes consul backend when configured', ->
    detectStub = sinon.stub(consul, 'detect')
    initStub = sinon.stub(consul, 'init')

    detectStub.returns(true)
    facade.init()
    assert.equal initStub.calledOnce, true

  it 'loads routes from consul backend', ->
    detectStub = sinon.stub(consul, 'detect')
    detectStub.returns(true)

    sinon.stub consul, 'init'
    sinon.stub(consul, 'getCachedRoutes').returns 'result': 'success'
    facade.init()
    routes = facade.getCachedRoutes()
    assert.equal routes.result, 'success'

  it 'loads services from consul backend', ->
    detectStub = sinon.stub(consul, 'detect')
    detectStub.returns(true)
    sinon.stub consul, 'init'

    sinon.stub(consul, 'getCachedHosts').returns 'result': 'success'

    facade.init()
    services = facade.getCachedHosts()
    assert.equal services.result, 'success'

  it 'throws exception if there is no backend defined', ->
    sinon.stub(consul, 'detect').returns(false);
    sinon.stub(redis, 'detect').returns(false);

    try
      facade.init()
      assert.fail 'should have thrown an error'
    catch error


  afterEach ->
    restore config.has
    restore consul.init
    restore consul.detect
    restore redis.detect
    restore consul.getRoutes
    restore consul.getHosts
