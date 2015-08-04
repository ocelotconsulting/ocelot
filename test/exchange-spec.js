var assert = require("assert"),
    config = require("config"),
    sinon = require("sinon"),
    consul = require('../src/metadata/consul.js'),
    cache = require('../src/metadata/cache.js');

describe('exchange', function () {

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