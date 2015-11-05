assert = require 'assert'
config = require 'config'
sinon = require 'sinon'
consul = require '../src/backend/consul.coffee'
facade = require '../src/backend/facade.coffee'
describe 'facade', ->

    restore = (mockFunc) ->
        if mockFunc.restore
            mockFunc.restore()

    it 'initializes consul backend when configured', ->
        sinon.stub(config, 'has', (arg) ->
            arg == 'backend.consul' or arg == 'jwks.url'
        )
        stub = sinon.stub(consul, 'init')
        facade.init()
        assert.equal stub.calledOnce, true

    it 'loads routes from consul backend', ->
        sinon.stub(config, 'has', (arg) ->
            arg == 'backend.consul' or arg == 'jwks.url'
        )
        sinon.stub consul, 'init'
        sinon.stub(consul, 'getRoutes').returns 'result': 'success'
        facade.init()
        routes = facade.getRoutes()
        assert.equal routes.result, 'success'

    it 'loads services from consul backend', ->
        sinon.stub(config, 'has', (arg) ->
            arg == 'backend.consul' or arg == 'jwks.url'
        )
        sinon.stub consul, 'init'
        sinon.stub(consul, 'getServices').returns 'result': 'success'
        facade.init()
        services = facade.getServices()
        assert.equal services.result, 'success'

    it 'throws exception if there is no backend defined', ->
        backendStub = sinon.stub(config, 'has', (arg) ->
            arg == 'backend.consul' or arg == 'jwks.url'
        )
        initCacheStub = sinon.stub(consul, 'init')
        try
            facade.init()
            assert.fail 'should have thrown an error'
        catch error
            assert backendStub.calledTwice == true
            assert initCacheStub.calledOnce == true

    afterEach ->
        restore config.has
        restore consul.init
        restore consul.getRoutes
        restore consul.getServices
