var assert = require("assert"),
    config = require("config"),
    sinon = require("sinon"),
    consul = require('../src/backend/consul.coffee'),
    cache = require('../src/backend/cache.coffee');

describe('cache', function () {

    it('initializes consul backend when configured', function () {
        sinon.stub(config, "has").withArgs("backend.consul").returns(true);
        var stub = sinon.stub(consul, "initCache");

        cache.initCache();
        assert.equal(stub.calledOnce, true);
    });

    it('loads routes from consul backend', function () {
        sinon.stub(config, "has").withArgs('backend.consul').returns(true);
        sinon.stub(consul, "initCache");
        sinon.stub(consul, "getRoutes").returns({"result": "success"});

        cache.initCache();

        routes = cache.getRoutes();

        assert.equal(routes.result, "success");
    });

    it('loads services from consul backend', function () {
        sinon.stub(config, "has").withArgs('backend.consul').returns(true);
        sinon.stub(consul, "initCache");
        sinon.stub(consul, "getServices").returns({"result": "success"});

        cache.initCache();

        services = cache.getServices();

        assert.equal(services.result, "success");
    });

    it('throws exception if there is no backend defined', function () {
        var backendStub = sinon.stub(config, "has").withArgs('backend.consul').returns(true);
        var initCacheStub = sinon.stub(consul, "initCache");

        try {
            cache.initCache();
            assert.fail("should have thrown an error");
        }
        catch (error) {
            assert(backendStub.calledOnce === true);
            assert(initCacheStub.calledOnce === true);
        }
    });

    afterEach(function () {
        restore(config.has);
        restore(consul.initCache);
        restore(consul.getRoutes);
        restore(consul.getServices);
    });

    function restore(mockFunc) {
        if (mockFunc.restore) {
            mockFunc.restore();
        }
    }
});