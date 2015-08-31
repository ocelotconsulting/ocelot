var assert = require("assert"),
    sinon = require("sinon"),
    postman = require("../src/auth/postman"),
    redirect = require("../src/auth/redirect"),
    headers = require("../src/auth/headers.js"),
    refresh = require("../src/auth/refresh");

var postmanMock, headersMock, redirectMock;

describe('refresh', function () {
    it('refreshes if post is successful', function () {
        var req = {headers: {cookie: "something_rt=abc"}};
        var res = {id: 'res'};
        var route = {id: 'route'};
        var auth = {id: 'auth'};
        route['cookie-name'] = 'something';

        postmanMock = sinon.stub(postman, 'post');
        postmanMock.withArgs('grant_type=refresh_token&refresh_token=abc', route).returns(
            {then: function(s, f){
                s(auth);
            }}
        );

        redirectMock = sinon.stub(redirect, 'refreshPage');
        redirectMock.withArgs(req, res);

        headersMock = sinon.stub(headers, 'setAuthCookies');
        headersMock.withArgs(res, route, auth);

        refresh.token(req, res, route);

        assert(postmanMock.calledOnce === true);
        assert(redirectMock.calledOnce === true);
        assert(headersMock.calledOnce === true);
    });

    it('redirects if post is unsuccessful', function () {
        var req = {headers: {cookie: "something_rt=abc"}};
        var res = {id: 'res'};
        var route = {id: 'route'};
        var auth = {id: 'auth'};
        route['cookie-name'] = 'something';

        postmanMock = sinon.stub(postman, 'post');
        postmanMock.withArgs('grant_type=refresh_token&refresh_token=abc', route).returns(
            {then: function(s, f){
                f(auth);
            }}
        );

        redirectMock = sinon.stub(redirect, 'toAuthServer');
        redirectMock.withArgs(req, res, route);

        refresh.token(req, res, route);

        assert(postmanMock.calledOnce === true);
        assert(redirectMock.calledOnce === true);
    });

    afterEach(function () {
        restore(postmanMock);
        restore(headersMock);
        restore(redirectMock);
    });
});

function restore(mockFunc) {
    if (mockFunc && mockFunc.restore) {
        mockFunc.restore();
    }
}