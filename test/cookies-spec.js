var assert = require("assert"),
    cookies = require('../src/auth/cookies');

describe('cookies', function () {
    it('returns refresh token and token with path equal to route key', function () {
        var res = {};

        res.setHeader = function(name, value){
            this[name] = value;
        };

        var route = {};
        var authentication = {};

        route['cookie-name'] = "mycookie";
        route.route = "abc";

        authentication['refresh_token'] = "abc123";
        authentication['access_token'] = "def123";

        cookies.set(res, route, authentication);

        console.log('>> ' + res['Set-Cookie']);

        assert.equal(res['Set-Cookie'].indexOf('mycookie=def123; path=/abc') > -1, true);
        assert.equal(res['Set-Cookie'].indexOf('mycookie_rt=abc123; path=/abc') > -1, true);
    });

    it('overrides the route key if you have a cookie path on your route', function () {
        var res = {};

        res.setHeader = function(name, value){
            this[name] = value;
        };

        var route = {};
        var authentication = {};

        route['cookie-name'] = "mycookie";
        route['cookie-path'] = "/zzz";
        route.route = "abc";

        authentication['refresh_token'] = "abc123";
        authentication['access_token'] = "def123";

        cookies.set(res, route, authentication);

        assert.equal(res['Set-Cookie'].indexOf('mycookie=def123; path=/zzz') > -1, true);
        assert.equal(res['Set-Cookie'].indexOf('mycookie_rt=abc123; path=/zzz') > -1, true);
    });
});