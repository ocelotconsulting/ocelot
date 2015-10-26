var assert = require("assert"),
    sinon = require("sinon"),
    headers = require("../src/auth/headers"),
    redirect = require("../src/auth/redirect"),
    response = require("../src/response");

var responseMock;

describe('redirect', function () {
    it('can redirect current page for refresh', function () {
        var req = {headers: {host: "myhost/"}, url: "my/url"};
        var res = {};

        var setHeader = sinon.spy();
        setHeader.withArgs('Location', 'http://myhost/my/url');
        res.setHeader = setHeader;

        responseMock = sinon.mock(response, 'send');
        responseMock.expects('send').withArgs(res, 307).once();

        redirect.refreshPage(req, res);

        assert.equal(setHeader.withArgs('Location', 'https://myhost/my/url').calledOnce, true);
        responseMock.verify();
    });

    it('can redirect to oauth server', function () {
        var req = {headers: {host: "myhost/"}, url: "my/url", protocol: "http:"};
        var res = {};
        var route = {};
        route['client-id'] = 'abc123';

        var setHeader = sinon.spy();
        setHeader.withArgs('Location', 'http://myhost/my/url');
        res.setHeader = setHeader;

        responseMock = sinon.mock(response, 'send');
        responseMock.expects('send').withArgs(res, 307).once();

        redirect.startAuthCode(req, res, route);

        var expectedUrl =
            "https://test.amp.monsanto.com/as.authorization.oauth2?response_type=code&client_id=abc123&redirect_uri=https%3A%2F%2Fmyhost%2Fmy%2Furl%2Freceive-auth-token&state=aHR0cHM6Ly9teWhvc3QvbXkvdXJs"
        console.info(setHeader.lastCall.args);

        assert.equal(setHeader.withArgs('Location', expectedUrl).calledOnce, true);
            responseMock.verify();
    });

    afterEach(function () {
        restore(responseMock);
    });
});

function restore(mockFunc) {
    if (mockFunc && mockFunc.restore) {
        mockFunc.restore();
    }
}