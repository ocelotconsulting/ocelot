var assert = require("assert"),
    sinon = require("sinon"),
    headers = require("../src/auth/headers"),
    postman = require("../src/auth/postman"),
    exchange = require("../src/auth/exchange"),
    https = require("https"),
    validate = require("../src/auth/validate");

var postmanMock;

describe('validate', function () {
    it('resolves if no required validation', function (done) {
        var req = {};
        var route = {};
        route['require-auth'] = false;

        validate.authentication(req, route).then(function (auth) {
                assert.equal(auth.required, false);
                done();
            },
            function (auth) {
                assert.fail('auth failed!');
                done();
            });
    });

    it('rejects if required validation but none sent', function (done) {
        var req = {headers: ''};
        var route = {};

        validate.authentication(req, route).then(function (auth) {
                assert.fail('should have failed!');
                done();
            },
            function (auth) {
                assert.equal(auth.valid, false);
                assert.equal(auth.required, true);
                done();
            });
    });

    it('resolves if bearer token found and valid', function (done) {
        var req = {headers: {}};
        var route = {};
        var auth = {id: "myauth"};

        req.headers.authorization = 'bearer abc';

        postmanMock = sinon.stub(postman, 'postAs', function(query, client, secret){
            return {then: function(s, f){
                s(auth);
            }};
        });

        validate.authentication(req, route).then(function (returnedAuth) {
                assert.equal(auth, returnedAuth);
                done();
            },
            function (auth) {
                assert.fail('failed!');
                done();
            });
    });

    it('resolves if auth token found and valid', function (done) {
        var req = {headers: {cookie: 'mycookie=abc'}};
        var route = {};
        var auth = {id: "myauth"};

        route['cookie-name'] = 'mycookie';

        postmanMock = sinon.stub(postman, 'postAs', function(query, client, secret){
            return {then: function(s, f){
                s(auth);
            }};
        });

        validate.authentication(req, route).then(function (returnedAuth) {
                assert.equal(auth, returnedAuth);
                done();
            },
            function (auth) {
                assert.fail('failed!');
                done();
            });
    });

    it('rejects if auth token found but invalid', function (done) {
        var req = {headers: {cookie: 'mycookie=abc'}};
        var route = {};
        var auth = {id: "myauth"};

        route['cookie-name'] = 'mycookie';

        postmanMock = sinon.stub(postman, 'postAs', function(query, client, secret){
            return {then: function(s, f){
                f('you suck');
            }};
        });

        validate.authentication(req, route).then(function (returnedAuth) {
                assert.fail('should fail!');
                done();
            },
            function (auth) {
                assert.equal(auth.required, true);
                assert.equal(auth.valid, false);
                assert.equal(auth.error, 'you suck');
                done();
            });
    });



    afterEach(function () {
        restore(postmanMock);
    });
});

function restore(mockFunc) {
    if (mockFunc && mockFunc.restore) {
        mockFunc.restore();
    }
}

