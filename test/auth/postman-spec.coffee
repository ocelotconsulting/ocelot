assert = require("assert")
sinon = require("sinon")
headers = require("../../src/auth/headers")
postman = require("../../src/auth/postman")
exchange = require("../../src/auth/exchange")
https = require("https")
config = require("config")
httpAgent = require('../../src/http-agent')

[postmanMock, headerMock, configMock, httpsMock, agentMock] = []

createAgent = (andThen) ->
   url: ''
   typeValue: ''
   data: {}
   post: (url) ->
     @url = url
     @
   type: (typeValue) ->
     @typeValue = typeValue
     @
   send: (data) ->
     @data = merge(data, this.data)
     @
   then: andThen

describe 'postman', () ->
    pingUrl = "http://someurl/like/this"
    someQuery = {someKey: "someValue"}
    myclient = "myclient"
    mysecret = "mysecret"

    afterEach ->
        restore(httpsMock)
        restore(postmanMock)
        restore(headerMock)
        restore(configMock)
        restore(agentMock)

    it 'post happy path', (done) ->
        configMock = sinon.stub config, 'get'
        configMock.withArgs('authentication.token-endpoint').returns pingUrl

        agent = createAgent (pass, fail) ->
            return Promise.resolve().then () ->
                  pass({body: {"pass": true}});

        agentMock = sinon.stub(httpAgent, 'getAgent');
        agentMock.withArgs().returns(agent);

        postman.postAs(someQuery, myclient, mysecret).then () ->
            assert.equal(agent.typeValue, "form")
            assert.equal(agent.data.someKey, "someValue")
            assert.equal(agent.data['client_id'], myclient)
            assert.equal(agent.data['client_secret'], mysecret)
            done()
        , () -> done('post failed')


    it 'returns error from json response', (done) ->
        agent = createAgent (pass, fail) ->
          Promise.resolve().then () ->
            pass({statusCode: 404, text: '{"error": "error message"}'})

        agentMock = sinon.stub httpAgent, 'getAgent'
        agentMock.withArgs().returns(agent)

        postman.postAs(someQuery, myclient, mysecret).then () ->
            done('post should have failed');
        , (err) ->
            assert.equal(err, 'HTTP 404: {"error": "error message"}');
            assert.equal(agent.typeValue, "form");
            assert.equal(agent.data.someKey, "someValue");
            assert.equal(agent.data['client_id'], myclient);
            assert.equal(agent.data['client_secret'], mysecret);
            done()

restore = (mockFunc) ->
    if (mockFunc && mockFunc.restore)
        mockFunc.restore()

merge = (obj1, obj2) ->
    obj3 = {}
    for name, value of obj1
      obj3[name] = value
    for name, value of obj2
      obj3[name] = value
    obj3;
