assert = require 'assert'
config = require 'config'
oidc = require '../../src/auth/oidc'
sinon = require 'sinon'
httpAgent = require '../../src/http-agent'
Promise = require 'promise'
jwt = require 'jsonwebtoken'
cron = require 'node-crontab'

describe 'oidc', ->

  configGetStub = {}
  httpAgentStub = {}
  jwtVerifyStub = {}
  cronScheduleJobStub = {}

  beforeEach ->
    configGetStub = sinon.stub(config, 'get')
    httpAgentStub = sinon.stub(httpAgent, 'getAgent')
    jwtVerifyStub = sinon.stub(jwt, 'verify')
    cronScheduleJobStub = sinon.stub(cron, 'scheduleJob')

  afterEach ->
    configGetStub.restore()
    httpAgentStub.restore()
    jwtVerifyStub.restore()
    cronScheduleJobStub.restore()

  it 'can get token by custom header', ->
    req = {headers: {'oidc': 'sometoken'}}
    cookies = {}
    route = {}
    oidc.getToken(req, route, cookies)
      .then (token) ->
        assert.equal(token, 'sometoken')
      , (err) ->
        assert.fail('token could not be retrieved')


  it 'can get token by cookie', ->
    req = {headers: {}}
    cookies = {'some_oidc': 'sometoken'}
    route = {'cookie-name': 'some'}
    oidc.getToken(req, route, cookies)
    .then (token) ->
      assert.equal(token, 'sometoken')
    , (err) ->
      assert.fail('token could not be retrieved')

  it 'fails if no key found', (done) ->
    oidc.validate('eyJhbGciOiJSUzI1NiIsImtpZCI6IndrYWNuIn0.two.three').then(done).catch (err) ->
      assert.equal(err.invalid_oidc, true)
      done()
    .catch(done)

  it 'validates oidc signature if key found', (done) ->
    configGetStub.withArgs('jwks.url').returns 'http://someurl'
    keys = [{e: "AQAB", n: "qVtbZgG1Qkvx1XyLG8YdNxKbJVmEr3vkm8_l02qkYBn6IYdrnDYdmuw1i9xB9yKAZhsUXBfZzY1QYq2GpAZxHLFM9iSjwbK-3qmE2A5M5TdfkQ6B79E4yMwLbc0s1YQxnP7RZfivunRV2ZWQqMEcEET8jcGAa_27dHPge2_a4bMpQQzO_lJ_ea-bZ3UcKtuF1cIgN-mnO7_zpAT0F6WT51yG-nlRE-ER83xgGDIOMNjXihNQ1xJy-WjUdTPH7Wnm0magMWaK0iw5NwRowcYXw-QjfP5a0-9J3ynkKaySJLd_93JFvPLgYjSPresvbCYu_d98kF1jI2pcV4bciv0s0w", kid: "wkacn"}]

    agentStub = sinon.stub()
    agentStub.withArgs('http://someurl').returns(Promise.resolve({body: {keys: keys}}))

    httpAgentStub.returns({get: (url) -> agentStub(url)})
    jwtVerifyStub.returns true

    oidc.init()

    setTimeout () =>
      oidc.validate('eyJhbGciOiJSUzI1NiIsImtpZCI6IndrYWNuIn0.eyJzdWIiOiJjamNvZmYiLCJ6b25laW5mbyI6InJlZ2lvbiIsIndlYnNpdGUiOiJ3ZWJzaXRlIiwibmlja25hbWUiOiJDSFJJU1RPUEhFUiIsIm1pZGRsZV9uYW1lIjoiTWlkZGxlIG5hbWUiLCJlbWFpbF92ZXJpZmllZCI6ZmFsc2UsImxvY2FsZSI6IkxvY2FsZSIsInByZWZlcnJlZF91c2VybmFtZSI6ImNqY29mZiIsImdpdmVuX25hbWUiOiJDSFJJU1RPUEhFUiIsInVwZGF0ZWRfdGltZSI6InVwZGF0ZWRfdGltZSIsInBpY3R1cmUiOiJQaWN0dXJlIiwiQXBwbGljYXRpb25FbnRpdGxlbWVudHMiOiJBV1MtTW9uSVRTQS1Qcm9kLUFkbWluU1NPIiwiZW1haWwiOiJjaHJpc3RvcGhlci5qLmNvZmZtYW5AbW9uc2FudG8uY29tIiwiY24iOiJDSkNPRkYiLCJuYW1lIjoiQ0hSSVNUT1BIRVIiLCJiaXJ0aGRhdGUiOiJCaXJ0aGRhdGUiLCJnZW5kZXIiOiJnZW5kZXIiLCJmYW1pbHlfbmFtZSI6IkNPRkZNQU4iLCJ1c2VyX2lkIjoiQ0pDT0ZGIiwiZGlzcGxheU5hbWUiOiJDb2ZmbWFuLCBDaHJpc3RvcGhlciBKIiwiZ3JvdXAiOiJub3QtYXZhaWxhYmxlIiwicHJvZmlsZSI6InByb2ZpbGUiLCJhdWQiOiJPQ0VMT1QtVUkiLCJqdGkiOiJaeEtHZlpSN3pqUk81N2tBN3huQUlGIiwiaXNzIjoiaHR0cHM6XC9cL3Rlc3QuYW1wLm1vbnNhbnRvLmNvbSIsImlhdCI6MTQ1NDk5NDE4NiwiZXhwIjoxNDU1MDAxMzg2fQ.CwtkX94UEUQWHl50pH2ygzQHmBefTYXmzi0b6y7632oajNTot39XH4nj591o-ARU6JBLqlcluvnLVmp6kAt1DnL1Jk_NddOEvA09KVJfzO0epBitaa0ZGZq2tYn4L2jwhw7QNFdN_LD2RtbtXm9rWIdjHdhwMe4Wh6cqcaeHMhfrp6Kuw35p8TobxR9P5rX-QNLmiKuEHJYY3BJSg2eV2EMlQOLtHaWmyOze51cr4gvM_n502F5_olRr8UR_si8FJdx9Lk5j5aW7DvJq7uREnEJsGEX9I2ngujYc5R4YlP4jldj_eFgpftpNCDFZGj0oZzsGVourZdM4Rkj8f6SEKQ')
      .then (claims) ->
        assert.equal(claims['sub'], 'cjcoff')
        done()
      .catch (done)
    , 200


