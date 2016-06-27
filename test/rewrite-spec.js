var assert = require("assert"),
    rewrite = require('../src/rewrite');

describe('rewrite', function () {
    it('rewrites url, one capture group', function () {
        var route = {};
        route['capture-pattern'] = "(.*)";
        route['rewrite-pattern'] = "$1";
        route.services = ['service1'];
        route.instances = {};
        route.instances.service1 = [{url: 'abc.testy.com'}];

        var url = rewrite.mapRoute("123", route);
        assert.equal(url.href, "abc.testy.com/123")
    });

    it('rewrites url, strips off segment', function () {
        var route = {};
        route['capture-pattern'] = "abc/(.*)";
        route['rewrite-pattern'] = "$1";
        route.services = ['service1'];
        route.instances = {};
        route.instances.service1 = [{url: 'abc.testy.com'}];

        var url = rewrite.mapRoute("abc/123", route);
        assert.equal(url.href, "abc.testy.com/123")
    });

    it('rewrites url, strips off segment, adds segment', function () {
        var route = {};
        route['capture-pattern'] = "abc/(.*)";
        route['rewrite-pattern'] = "def/$1";
        route.services = ['service1'];
        route.instances = {};
        route.instances.service1 = [{url: 'abc.testy.com'}];

        var url = rewrite.mapRoute("abc/123", route);
        assert.equal(url.href, "abc.testy.com/def/123")
    });

    it('can have a leading slash on the rewrite without a problem', function () {
        var route = {};
        route['capture-pattern'] = "abc/(.*)";
        route['rewrite-pattern'] = "/def/$1";
        route.services = ['service1'];
        route.instances = {};
        route.instances.service1 = [{url: 'abc.testy.com'}];

        var url = rewrite.mapRoute("abc/123", route);
        assert.equal(url.href, "abc.testy.com/def/123")
    });

    it('rewrites a url with only a slash', function () {
        var route = {};
        route['capture-pattern'] = "(.*)";
        route['rewrite-pattern'] = "$1";
        route.services = ['service1'];
        route.instances = {};
        route.instances.service1 = [{url: 'abc.testy.com'}];

        var url = rewrite.mapRoute("/", route);
        assert.equal(url.href, "abc.testy.com/")
    });

    it('rewrites url, two capture groups', function () {
        var route = {};
        route['capture-pattern'] = "this/(.*)/that/(.*)";
        route['rewrite-pattern'] = "$1/$2";
        route.services = ['service1'];
        route.instances = {};
        route.instances.service1 = [{url: 'abc.testy.com'}];

        var url = rewrite.mapRoute("this/abc/that/def", route);
        assert.equal(url.href, "abc.testy.com/abc/def")
    });

    it('allows capture in path to be used in host', function () {
        var route = {};
        route['capture-pattern'] = "this/(.*)/that/(.*)";
        route['rewrite-pattern'] = "$1/$2";
        route.services = ['service1'];
        route.instances = {};
        route.instances.service1 = [{url: '$2.testy.com'}];

        var url = rewrite.mapRoute("this/abc/that/def", route);
        assert.equal(url.href, "def.testy.com/abc/def")
    });
});
