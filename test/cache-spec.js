var assert = require("assert"),
    config = require("config"),
    sinon = require("sinon"),
    consul = require('../src/backend/consul.js'),
    cache = require('../src/backend/cache.js');

describe('cache', function () {

    it('initializes consul backend when configured', function () {
        var called = false;

        sinon.stub(config, "has", function (type) {
            return type === "backend.consul";
        });
        sinon.stub(consul, "initCache", function () {
            called = true;
        });
        cache.initCache();
        assert.equal(called, true);
    });

    it('loads routes from consul backend', function () {
        var called = false;

        sinon.stub(config, "has", function (type) {
            return type === "backend.consul";
        });
        sinon.stub(consul, "initCache", function () {
            called = true;
        });
        sinon.stub(consul, "getRoutes", function () {
            return {"result": "success"};
        });
        cache.initCache();
        routes = cache.getRoutes();

        assert.equal(routes.result, "success");
    });

    it('loads services from consul backend', function () {
        var called = false;

        sinon.stub(config, "has", function (type) {
            return type === "backend.consul";
        });
        sinon.stub(consul, "initCache", function () {
            called = true;
        });
        sinon.stub(consul, "getServices", function () {
            return {"result": "success"};
        });
        cache.initCache();
        services = cache.getServices();

        assert.equal(services.result, "success");
    });

    it('throws exception if there is no backend defined', function () {
        var called = false;

        sinon.stub(config, "has", function (type) {
            return false;
        });
        sinon.stub(consul, "initCache", function () {
            called = true;
        });
        try {
            cache.initCache();
            assert.fail("should have thrown an error");
        }
        catch (error) {
            assert.equal(called, false);
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