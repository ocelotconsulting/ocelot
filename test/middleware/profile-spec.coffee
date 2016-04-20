profileMiddleware = require '../../src/middleware/profile'
tokenProvider = require '../../src/token-provider'
profile = require '../../src/auth/profile'
Promise = require 'promise'
sinon = require 'sinon'
chai = require 'chai'

expect = chai.expect

sandbox = sinon.sandbox.create()

describe 'profile middleware', (done) ->

  afterEach ->
    sandbox.restore()

  it 'sets the profile on the current request', ->
    route =
      route: 'my.route'
    req =
      url: "/abc"
      _route: route
      _auth: 'myauth'
    res = {setHeader: sandbox.stub()}

    myprofile = {awesome: 'yes'}

    next = sandbox.stub()
    tokenProviderStub = sandbox.stub(tokenProvider, 'getToken').returns Promise.resolve('abcxyz')
    profileStub = sandbox.stub(profile, 'getProfile').returns Promise.resolve(myprofile)

    profileMiddleware(req,res,next)

    setTimeout 200, () ->
      expect(next.called).to.be.true
      expect(req._profile).to.eql myprofile
      done()

  it 'next still gets called on errors', ->
    route =
      route: 'my.route'
    req =
      url: "/abc"
      _route: route
      _auth: 'myauth'
    res = {setHeader: sandbox.stub()}

    myprofile = {awesome: 'yes'}

    next = sandbox.stub()
    tokenProviderStub = sandbox.stub(tokenProvider, 'getToken').returns Promise.reject('some error')

    profileMiddleware(req,res,next)

    setTimeout 300, () ->
      expect(next.called).to.be.true
      expect(req._profile).to.not.exist
      done()
