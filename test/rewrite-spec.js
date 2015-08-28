var assert = require("assert"),
    rewrite = require('../src/rewrite');

describe('rewrite', function () {
    it('rewrites url, one capture group', function () {
        var route = {};
        route['capture-pattern'] = "(.*)";
        route['rewrite-pattern'] = "$1";
        route.services = ['service1'];
        route.instances = {};
        route.instances.service1 = [{url: 'abc.monsanto.com'}];

        var url = rewrite.mapRoute("123", route);
        assert.equal(url.href, "abc.monsanto.com/123")
    });

    it('rewrites url, strips off segment', function () {
        var route = {};
        route['capture-pattern'] = "abc/(.*)";
        route['rewrite-pattern'] = "$1";
        route.services = ['service1'];
        route.instances = {};
        route.instances.service1 = [{url: 'abc.monsanto.com'}];

        var url = rewrite.mapRoute("abc/123", route);
        assert.equal(url.href, "abc.monsanto.com/123")
    });

    it('rewrites url, strips off segment, adds segment', function () {
        var route = {};
        route['capture-pattern'] = "abc/(.*)";
        route['rewrite-pattern'] = "def/$1";
        route.services = ['service1'];
        route.instances = {};
        route.instances.service1 = [{url: 'abc.monsanto.com'}];

        var url = rewrite.mapRoute("abc/123", route);
        assert.equal(url.href, "abc.monsanto.com/def/123")
    });

    it('you can have a leading slash on the rewrite l without a problem', function () {
        var route = {};
        route['capture-pattern'] = "abc/(.*)";
        route['rewrite-pattern'] = "/def/$1";
        route.services = ['service1'];
        route.instances = {};
        route.instances.service1 = [{url: 'abc.monsanto.com'}];

        var url = rewrite.mapRoute("abc/123", route);
        assert.equal(url.href, "abc.monsanto.com/def/123")
    });
});