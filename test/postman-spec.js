var assert = require("assert"),
    sinon = require("sinon"),
    headers = require("../src/auth/headers"),
    postman = require("../src/auth/postman"),
    exchange = require("../src/auth/exchange"),
    https = require("https"),
    config = require("config");

var postmanMock, headerMock, configMock, httpsMock;

describe('postman', function () {
    var pingUrl = "http://someurl/like/this";
    var someQuery = "this=that";
    var myclient = "myclient";
    var mysecret = "mysecret";

    it('post happy path', function (done) {
        configMock = sinon.stub(config, 'get');
        configMock.withArgs('authentication.token-endpoint').returns(pingUrl);

        httpsMock = createHttpsStub('{"some": "data"}');

        postman.post(someQuery, myclient, mysecret).then(function () {
            done();
        }, function () {
            assert.fail('post failed!');
            done();
        });

        httpsArgs = httpsMock.args[0][0];
        assert.equal(httpsArgs.host, "test.amp.monsanto.com");
        assert.equal(httpsArgs.path, "/as/token.oauth2?this=that");
        assert.equal(httpsArgs.method, "POST");
    });

    it('returns error from json response', function (done) {
        configMock = sinon.stub(config, 'get');
        configMock.withArgs('authentication.token-endpoint').returns(pingUrl);

        httpsMock = createHttpsStub('{"error": "you suck"}');

        postman.post(someQuery, myclient, mysecret).then(function () {
            assert.fail('post succeeded!');
            done();
        }, function (error) {
            assert.equal(error, 'you suck');
            done();
        });
    });

    it('returns error if not json response', function (done) {
        configMock = sinon.stub(config, 'get');
        configMock.withArgs('authentication.token-endpoint').returns(pingUrl);

        httpsMock = createHttpsStub('tartar sauce');

        postman.post(someQuery, myclient, mysecret).then(function () {
            assert.fail('post succeeded!');
            done();
        }, function (error) {
            assert.equal(error, 'could not parse JSON response: tartar sauce');
            done();
        });
    });

    function createHttpsStub(data){
        return sinon.stub(https, 'request', function(options, f){
            var res = {};

            res.on = function(thing, f){
                if(thing === 'data'){
                    f(data);
                }
                else{
                    f();
                }
            };

            res.setEncoding = function(encoding){
                assert.equal(encoding, 'utf8');
            };

            f(res);
        });
    }

    afterEach(function () {
        restore(httpsMock);
        restore(postmanMock);
        restore(headerMock);
        restore(configMock);
    });
});

function restore(mockFunc) {
    if (mockFunc && mockFunc.restore) {
        mockFunc.restore();
    }
}