var assert = require("assert"),
    sinon = require("sinon"),
    headers = require("../src/auth/headers"),
    postman = require("../src/auth/postman"),
    exchange = require("../src/auth/exchange");

var postmanMock, headerMock;

describe('exchange', function () {
    it('returns 500 when exchange fails', function () {
        var req = {url: "http://host?state=dGVzdA%3D%3D&code=abc"};
        var res = {end: function(){
            this.ended = true;
        }, ended: false};
        var route = {};

        postmanMock = sinon.stub(postman, "post");
        postmanMock.withArgs('grant_type=authorization_code&code=abc&redirect_uri=test%2Freceive-auth-token', route).returns(
            {then: function(success,failure){
                failure('error message');
            }}
        );

        exchange.code(req, res, route);

        assert.equal(res.statusCode, 500);
        assert.equal(res.ended, true);
    });

    it('exchanges code for token, sets token cookie', function () {
        var req = {url: "http://host?state=dGVzdA%3D%3D&code=abc"};
        var res = {end: function(){
            this.ended = true;
        }, ended: false,
        setHeader: function(name, value){
            this.headers[this.headers.length] = {name: name, value: value};
        }, headers: []};
        var route = {};
        var payload = {id: "payload"};

        headerMock = sinon.mock(headers, "setAuthCookies");
        headerMock.expects("setAuthCookies").once().withArgs(res, route, payload);

        postmanMock = sinon.stub(postman, "post");
        postmanMock.withArgs('grant_type=authorization_code&code=abc&redirect_uri=test%2Freceive-auth-token', route).returns(
            {then: function(success,failure){
                success(payload);
            }}
        );

        exchange.code(req, res, route);

        headerMock.verify();

        assert.equal(res.statusCode, 307);
        assert.equal(res.ended, true);
        assert.equal(res.headers.length, 1);
        assert.equal(res.headers[0].name, "Location");
        assert.equal(res.headers[0].value, "test");
    });

    afterEach(function () {
        restore(postmanMock);
        restore(headerMock);
    });
});

function restore(mockFunc) {
    if (mockFunc && mockFunc.restore) {
        mockFunc.restore();
    }
}