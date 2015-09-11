var assert = require("assert"),
    headers = require('../src/auth/headers'),
    crypt = require('../src/auth/crypt');

var res = {};
var route = {};
var authentication = {};
var auth = {};

beforeEach(function(){
    res = {};
    route = {};
    authentication = {};
    auth = {};
});

describe('headers', function () {

    it('returns tokens with path equal to route key', function () {
        res.setHeader = function(name, value){
            this[name] = value;
        };
        route['cookie-name'] = "mycookie";
        route['route'] = "abc";
        route['client-secret'] = "secret";
        authentication['refresh_token'] = "abc123";
        authentication['access_token'] = "def123";
        authentication['id_token'] = "ghi123";

        headers.setAuthCookies(res, route, authentication);

        assert.equal(res['Set-Cookie'].indexOf('mycookie=def123; path=/abc') > -1, true);
        assert.equal(res['Set-Cookie'].indexOf('mycookie_rt='+ crypt.encrypt(authentication.refresh_token, route['client-secret']) + '; path=/abc') > -1, true);
        assert.equal(res['Set-Cookie'].indexOf('mycookie_oidc=ghi123; path=/abc') > -1, true);
    });

    it('omit refresh or oidc token when not present', function () {
        res.setHeader = function(name, value){
            this[name] = value;
        };
        route['cookie-name'] = "mycookie";
        route.route = "abc";
        authentication['access_token'] = "def123";
        headers.setAuthCookies(res, route, authentication);

        assert.equal(res['Set-Cookie'].indexOf('mycookie=def123; path=/abc') > -1, true);
        assert.equal(res['Set-Cookie'].indexOf('mycookie_rt=abc123; path=/abc') > -1, false);
        assert.equal(res['Set-Cookie'].indexOf('mycookie_oidc=ghi123; path=/abc') > -1, false);
    });

    it('overrides the route key if you have a cookie path on your route', function () {
        res.setHeader = function(name, value){
            this[name] = value;
        };
        route['cookie-name'] = "mycookie";
        route['cookie-path'] = "/zzz";
        route['route'] = "abc";
        route['client-secret'] = "secret";

        authentication['refresh_token'] = "abc123";
        authentication['access_token'] = "def123";

        headers.setAuthCookies(res, route, authentication);

        assert.equal(res['Set-Cookie'].indexOf('mycookie=def123; path=/zzz') > -1, true);
        assert.equal(res['Set-Cookie'].indexOf('mycookie_rt='+ crypt.encrypt(authentication.refresh_token, route['client-secret']) + '; path=/zzz') > -1, true);
    });
});

describe('auth headers', function(){
    it('adds user header if oidc token exists and encodes a subject', function(){
        var req = {headers: {}};
        req.headers.cookie = "this=that";
        auth = {client_id: "some-app", valid: true};
        route['user-header'] = 'user-id';
        route['cookie-name'] = 'my-cookie';
        req.headers['cookie'] = 'this=that; my-cookie_oidc=abc.eyJzdWIiOiJjamNvZmYifQ==.abc';

        headers.addAuth(req, route, auth);

        assert.equal(req.headers['user-id'], 'cjcoff');
    });

    it('omits user header if oidc token missing', function(){
        var req = {headers: {}};
        req.headers.cookie = "this=that";
        auth = {client_id: "some-app", valid: true};
        route['user-header'] = 'user-id';
        route['cookie-name'] = 'my-cookie';
        req.headers['cookie'] = 'this=that;';

        headers.addAuth(req, route, auth);

        assert.equal(!req.headers['user-id'], true);
    });

    it('adds client header if one exists on the validation payload', function(){
        var req = {headers: {}};
        req.headers.cookie = "this=that";
        auth = {client_id: "some-app", valid: true};
        route['client-header'] = 'client-id';
        req.headers['cookie'] = 'this=that;';

        headers.addAuth(req, route, auth);

        assert.equal(req.headers['client-id'], 'some-app');
    });

    it('omits client header if missing from authorization', function(){
        var req = {headers: {}};
        req.headers.cookie = "this=that";
        auth = {valid: true};
        route['client-header'] = 'client-id';
        req.headers['cookie'] = 'this=that;';

        headers.addAuth(req, route, auth);

        assert.equal(!req.headers['client-id'], true);
    });
});