var assert = require("assert"),
    sinon = require("sinon"),
    headers = require("../../src/auth/headers"),
    postman = require("../../src/auth/postman"),
    exchange = require("../../src/auth/exchange"),
    https = require("https"),
    config = require("config"),
    httpAgent = require('../../src/http-agent'),
    Promise = require('promise');

var postmanMock, headerMock, configMock, httpsMock, agentMock;

var createAgent = function(then){
   return {
       url: '',
       typeValue: '',
       data: {},
       post: function (url) {
           this.url = url;
           return this;
       },
       type: function (typeValue) {
           this.typeValue = typeValue;
           return this;
       },
       send: function (data) {
           this.data = merge(data, this.data);
           return this;
       },
       then: then
   }
};

describe('postman', function () {
    var pingUrl = "http://someurl/like/this";
    var someQuery = {someKey: "someValue"};
    var myclient = "myclient";
    var mysecret = "mysecret";

    it('post happy path', function (done) {
        configMock = sinon.stub(config, 'get');
        configMock.withArgs('authentication.token-endpoint').returns(pingUrl);

        agent = createAgent(function (pass, fail) {
            return Promise.resolve().then(function() {
                    return pass({text: '{"pass": true}'});
                }
            );
        });

        agentMock = sinon.stub(httpAgent, 'getAgent');
        agentMock.withArgs().returns(agent);

        postman.postAs(someQuery, myclient, mysecret).then(function () {
            assert.equal(agent.typeValue, "form");
            assert.equal(agent.data.someKey, "someValue");
            assert.equal(agent.data['client_id'], myclient);
            assert.equal(agent.data['client_secret'], mysecret);
            done();
        }, function () {
            done('post failed');
        });
    });

    it('returns error from json response', function (done) {
        agent = createAgent(function (pass, fail) {
            return Promise.resolve().then(function() {
                    return pass({statusCode: 404, text: '{"error": "error message"}'});
                }
            );
        });

        agentMock = sinon.stub(httpAgent, 'getAgent');
        agentMock.withArgs().returns(agent);

        postman.postAs(someQuery, myclient, mysecret).then(function () {
            done('post should have failed');
        }, function (err) {
            assert.equal(err, 'HTTP 404: {"error": "error message"}');
            assert.equal(agent.typeValue, "form");
            assert.equal(agent.data.someKey, "someValue");
            assert.equal(agent.data['client_id'], myclient);
            assert.equal(agent.data['client_secret'], mysecret);
            done();
        });
    });

    afterEach(function () {
        restore(httpsMock);
        restore(postmanMock);
        restore(headerMock);
        restore(configMock);
        restore(agentMock)
    });
});

function merge(obj1,obj2){
    var obj3 = {};
    for (var attrname in obj1) { obj3[attrname] = obj1[attrname]; }
    for (var attrname in obj2) { obj3[attrname] = obj2[attrname]; }
    return obj3;
}

function restore(mockFunc) {
    if (mockFunc && mockFunc.restore) {
        mockFunc.restore();
    }
}