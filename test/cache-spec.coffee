assert = require 'assert'
config = require 'config'
sinon = require 'sinon'
consul = require '../src/backend/consul.coffee'
cache = require '../src/backend/cache.coffee'
describe 'cache', ->

    restore = (mockFunc) ->
        if mockFunc.restore
            mockFunc.restore()

    it 'initializes consul backend when configured', ->
        sinon.stub(config, 'has', (arg) ->
            arg == 'backend.consul' or arg == 'jwks.url'
        )
        stub = sinon.stub(consul, 'initCache')
        cache.initCache()
        assert.equal stub.calledOnce, true

    it 'loads routes from consul backend', ->
        sinon.stub(config, 'has', (arg) ->
            arg == 'backend.consul' or arg == 'jwks.url'
        )
        sinon.stub consul, 'initCache'
        sinon.stub(consul, 'getRoutes').returns 'result': 'success'
        cache.initCache()
        routes = cache.getRoutes()
        assert.equal routes.result, 'success'

    it 'loads services from consul backend', ->
        sinon.stub(config, 'has', (arg) ->
            arg == 'backend.consul' or arg == 'jwks.url'
        )
        sinon.stub consul, 'initCache'
        sinon.stub(consul, 'getServices').returns 'result': 'success'
        cache.initCache()
        services = cache.getServices()
        assert.equal services.result, 'success'

    it 'throws exception if there is no backend defined', ->
        backendStub = sinon.stub(config, 'has', (arg) ->
            arg == 'backend.consul' or arg == 'jwks.url'
        )
        initCacheStub = sinon.stub(consul, 'initCache')
        try
            cache.initCache()
            assert.fail 'should have thrown an error'
        catch error
            assert backendStub.calledTwice == true
            assert initCacheStub.calledOnce == true

    afterEach ->
        restore config.has
        restore consul.initCache
        restore consul.getRoutes
        restore consul.getServices
