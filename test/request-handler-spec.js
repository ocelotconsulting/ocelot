var assert = require("assert"),
    cors = require('../src/cors'),
    requestHandler = require('../src/request-handler'),
    sinon = require("sinon"),
    resolver = require("../src/resolver"),
    rewrite = require("../src/rewrite"),
    exchange = require("../src/auth/exchange"),
    validate = require("../src/auth/validate"),
    refresh = require("../src/auth/refresh"),
    redirect = require("../src/auth/redirect"),
    proxy = require("../src/proxy"),
    headers = require("../src/auth/headers"),
    response = require('../src/response');

var px = {
    id: "proxy stub"
};

var corsHeadersMock, responseMock, preflightMock, resolverMock, exchangeMock, rewriteMock,
    validateMock, refreshMock, redirectMock, proxyMock, headersProxy;

var req, res, handler = null;

var presumeHost = function (req) {
    presumeHostReq = req;
};

beforeEach(function () {
    req, res = null;
    handler = requestHandler.create(px, presumeHost);
});

describe('request handler', function () {
    it('delegates cors requests', function () {

        preflightMock = sinon.stub(cors, "preflight");
        preflightMock.withArgs(req).returns(true);

        corsHeadersMock = sinon.mock(cors);
        responseMock = sinon.mock(response);

        corsHeadersMock.expects("setCorsHeaders").once().withArgs(req, res);
        responseMock.expects("send").once().withArgs(res, 204);

        handler(req, res);

        corsHeadersMock.verify();
        responseMock.verify();
    });

    it('returns 404 on missing route', function () {
        req = {url: "http://someurl"};

        preflightMock = sinon.stub(cors, "preflight");
        preflightMock.withArgs(req).returns(false);

        corsHeadersMock = sinon.stub(cors, "setCorsHeaders");
        corsHeadersMock.withArgs(req, res);

        responseMock = sinon.mock(response);
        responseMock.expects("send").once().withArgs(res, 404, "Route not found");
        resolverMock = sinon.mock(resolver);
        resolverMock.expects("resolveRoute").once().withArgs(req.url).returns(null);

        handler(req, res);

        resolverMock.verify();
        responseMock.verify();
    });

    it('performs token exchange if url ends with receive-auth-token', function () {
        req = {url: "http://someurl/receive-auth-token"};
        var route = {id: "my route"};

        preflightMock = sinon.stub(cors, "preflight");
        preflightMock.withArgs(req).returns(false);
        corsHeadersMock = sinon.stub(cors, "setCorsHeaders");
        corsHeadersMock.withArgs(req, res);
        resolverMock = sinon.stub(resolver, "resolveRoute");
        resolverMock.withArgs(req.url).returns(route);

        exchangeMock = sinon.mock(exchange);
        exchangeMock.expects("code").once().withArgs(req, res, route).returns(route);

        handler(req, res);

        exchangeMock.verify();
        responseMock.verify();
    });

    it('returns 404 if url not found', function () {
        req = {url: "http://someurl"};
        var route = {id: "my route"};

        preflightMock = sinon.stub(cors, "preflight");
        preflightMock.withArgs(req).returns(false);
        corsHeadersMock = sinon.stub(cors, "setCorsHeaders");
        corsHeadersMock.withArgs(req, res);
        resolverMock = sinon.stub(resolver, "resolveRoute");
        resolverMock.withArgs(req.url).returns(route);

        rewriteMock = sinon.mock(rewrite);
        rewriteMock.expects("mapRoute").once().withArgs(req.url, route).returns(null);
        responseMock = sinon.mock(response);
        responseMock.expects("send").once().withArgs(res, 404, "No active URL for route");

        handler(req, res);

        responseMock.verify();
        rewriteMock.verify();
    });

    it('tries refresh if auth fails and refresh is possible', function () {
        req = {url: "http://someurl"};
        var route = {id: "my route"};
        var rewrittenUrl = "http://someotherurl";
        var auth = {refresh: true};

        preflightMock = sinon.stub(cors, "preflight");
        preflightMock.withArgs(req).returns(false);
        corsHeadersMock = sinon.stub(cors, "setCorsHeaders");
        corsHeadersMock.withArgs(req, res);
        resolverMock = sinon.stub(resolver, "resolveRoute");
        resolverMock.withArgs(req.url).returns(route);
        rewriteMock = sinon.stub(rewrite, "mapRoute");
        rewriteMock.withArgs(req.url, route).returns(rewrittenUrl);

        validateMock = sinon.stub(validate, "authentication");
        validateMock.withArgs(req, route).returns(
            {then: function(success, fail){
                fail(auth);
            }}
        );

        refreshMock = sinon.mock(refresh);
        refreshMock.expects("token").once().withArgs(req, res, route);

        handler(req, res);

        refreshMock.verify();
    });

    it('tries redirect if auth fails and refresh not possible', function () {
        req = {url: "http://someurl"};
        var route = {id: "my route"};
        var rewrittenUrl = "http://someotherurl";
        var auth = {refresh: false, redirect: true};

        preflightMock = sinon.stub(cors, "preflight");
        preflightMock.withArgs(req).returns(false);
        corsHeadersMock = sinon.stub(cors, "setCorsHeaders");
        corsHeadersMock.withArgs(req, res);
        resolverMock = sinon.stub(resolver, "resolveRoute");
        resolverMock.withArgs(req.url).returns(route);
        rewriteMock = sinon.stub(rewrite, "mapRoute");
        rewriteMock.withArgs(req.url, route).returns(rewrittenUrl);

        validateMock = sinon.stub(validate, "authentication");
        validateMock.withArgs(req, route).returns(
            {then: function(success, fail){
                fail(auth);
            }}
        );

        redirectMock = sinon.mock(redirect);
        redirectMock.expects("toAuthServer").once().withArgs(req, res, route);

        handler(req, res);

        redirectMock.verify();
    });

    it('returns error if auth fails, no possible refresh or redirect', function () {
        req = {url: "http://someurl"};
        var route = {id: "my route"};
        var rewrittenUrl = "http://someotherurl";
        var auth = {refresh: false, redirect: false};

        preflightMock = sinon.stub(cors, "preflight");
        preflightMock.withArgs(req).returns(false);
        corsHeadersMock = sinon.stub(cors, "setCorsHeaders");
        corsHeadersMock.withArgs(req, res);
        resolverMock = sinon.stub(resolver, "resolveRoute");
        resolverMock.withArgs(req.url).returns(route);
        rewriteMock = sinon.stub(rewrite, "mapRoute");
        rewriteMock.withArgs(req.url, route).returns(rewrittenUrl);

        validateMock = sinon.stub(validate, "authentication");
        validateMock.withArgs(req, route).returns(
            {then: function(success, fail){
                fail(auth);
            }}
        );

        responseMock = sinon.mock(response);
        responseMock.expects("send").once().withArgs(res, 403, "Authorization missing or invalid");

        handler(req, res);

        responseMock.verify();
    });

    it('has a happy path through proxy land', function () {
        req = {url: "http://someurl"};
        var route = {id: "my route"};
        var rewrittenUrl = "http://someotherurl";
        var auth = {refresh: false, redirect: false};

        preflightMock = sinon.stub(cors, "preflight");
        preflightMock.withArgs(req).returns(false);
        corsHeadersMock = sinon.stub(cors, "setCorsHeaders");
        corsHeadersMock.withArgs(req, res);
        resolverMock = sinon.stub(resolver, "resolveRoute");
        resolverMock.withArgs(req.url).returns(route);
        rewriteMock = sinon.stub(rewrite, "mapRoute");
        rewriteMock.withArgs(req.url, route).returns(rewrittenUrl);

        validateMock = sinon.stub(validate, "authentication");
        validateMock.withArgs(req, route).returns(
            {then: function(success, fail){
                success(auth);
            }}
        );

        headersProxy = sinon.mock(headers);
        headersProxy.expects("addAuth").once().withArgs(req, route, auth);

        proxyMock = sinon.mock(proxy);
        proxyMock.expects("request").once().withArgs(px, req, res, rewrittenUrl);

        handler(req, res);

        responseMock.verify();
        headersProxy.verify();
    });

    afterEach(function () {
        restore(corsHeadersMock);
        restore(responseMock);
        restore(preflightMock);
        restore(resolverMock);
        restore(exchangeMock);
        restore(validateMock);
        restore(rewriteMock);
        restore(refreshMock);
        restore(redirectMock);
        restore(proxyMock);
        restore(headers);
    });
});

function restore(mockFunc) {
    if (mockFunc && mockFunc.restore) {
        mockFunc.restore();
    }
}