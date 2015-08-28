var assert = require('assert'),
    sinon = require('sinon'),
    cache = require('../src/backend/cache'),
    resolver = require('../src/resolver');

describe('resolver', function () {

    afterEach(function () {
        restore(cache.getRoutes);
        restore(cache.getServices);
    });

    it('return null if cannot find route', function () {
        sinon.stub(cache, "getRoutes", function () {
            return [{}];
        });

        assert.equal(resolver.resolveRoute("http://monsanto.com/abc"), null);
    });

    it('returns route if found, level 1', function () {
        sinon.stub(cache, "getRoutes", function () {
            return [{route: 'abc'}];
        });

        assert.equal(resolver.resolveRoute("http://monsanto.com/abc").route, 'abc');
    });

    it('returns route if found, level 2', function () {
        sinon.stub(cache, "getRoutes", function () {
            return [{route: 'abc/def'}];
        });

        assert.equal(resolver.resolveRoute("http://monsanto.com/abc/def").route, 'abc/def');
    });

    it('returns route if found, level 3', function () {
        sinon.stub(cache, "getRoutes", function () {
            return [{route: 'abc/def/ghi'}];
        });

        assert.equal(resolver.resolveRoute("http://monsanto.com/abc/def/ghi").route, 'abc/def/ghi');
    });

    it('does not go to level 4', function () {
        sinon.stub(cache, "getRoutes", function () {
            return [{route: 'abc/def/ghi/jkl'}];
        });

        assert.equal(resolver.resolveRoute("http://monsanto.com/abc/def/ghi/jkl"), null);
    });

    it('uses closest path', function () {
        sinon.stub(cache, "getRoutes", function () {
            return [{route: 'abc/def'}];
        });

        assert.equal(resolver.resolveRoute("http://monsanto.com/abc/def/ghi").route, 'abc/def');
    });

    it('returns whole cache object', function () {
        sinon.stub(cache, "getRoutes", function () {
            return [{route: 'abc/def', fruit: "banana"}];
        });

        assert.equal(resolver.resolveRoute("http://monsanto.com/abc/def/ghi").fruit, 'banana');
    });

    it('adds service urls', function () {
        sinon.stub(cache, "getRoutes", function () {
            return [{route: 'abc/def', services: ['service1']}];
        });

        sinon.stub(cache, "getServices", function () {
            return {service1: [{url: "www.monsanto.com"}]};
        });

        assert.equal(resolver.resolveRoute("http://monsanto.com/abc/def/ghi").instances.service1[0].url, 'www.monsanto.com');
    });

    function restore(mockFunc) {
        if (mockFunc.restore) {
            mockFunc.restore();
        }
    }
});