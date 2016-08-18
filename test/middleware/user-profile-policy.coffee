profile = require '../../src/auth/profile'
sinon = require 'sinon'
chai = require 'chai'
userProfilePolicy = require '../../src/middleware/user-profile-policy'
response = require '../../src/response'

expect = chai.expect
sandbox = sinon.sandbox.create()

describe 'profile policy middleware', ->

  res = {}

  afterEach ->
    sandbox.restore()

  beforeEach ->
    sandbox.stub response, 'send'

  it 'does not filter if policy is unset', ->
    req =
      _route: {}
    next = sinon.stub()
    userProfilePolicy(req, res, next)

    expect(next.called).to.be.true

  it 'does not filter if policy is satisfied', ->
    req =
      _profile:
        user: 'cjcoff'
      _route:
        'user-profile-policy': [
            pathOperand: 'user'
            operator: 'equals'
            valueOperand: 'cjcoff'
        ]
    next = sinon.stub()

    userProfilePolicy(req, res, next)

    expect(next.called).to.be.true

  it 'filters if policy is not satisfied', ->
    req =
      _profile:
        user: 'dbtand'
      _route:
        'user-profile-policy': [
            pathOperand: 'user'
            operator: 'equals'
            valueOperand: 'cjcoff'
        ]
    next = sinon.stub()

    userProfilePolicy(req, res, next)

    expect(next.called).to.be.false

  it 'allows in list policies', ->
    req =
      _profile:
        entitlements: ['user', 'admin']
      _route:
        'user-profile-policy': [
            pathOperand: 'entitlements'
            operator: 'contains'
            valueOperand: 'user'
        ]
    next = sinon.stub()

    userProfilePolicy(req, res, next)

    expect(next.called).to.be.true

  it 'policy allows equalsIgnoreCase', ->
    req =
      _profile:
        user: 'CjcoFF'
      _route:
        'user-profile-policy': [
            pathOperand: 'user'
            operator: 'equalsIgnoreCase'
            valueOperand: 'cjcoff'
        ]
    next = sinon.stub()

    userProfilePolicy(req, res, next)

    expect(next.called).to.be.true

  it 'policy allows inList', ->
    req =
      _profile:
        user: 'cjcoff'
      _route:
        'user-profile-policy': [
            pathOperand: 'user'
            operator: 'inList'
            valueOperand: ['dbtand', 'cjcoff']
        ]
    next = sinon.stub()

    userProfilePolicy(req, res, next)

    expect(next.called).to.be.true

  it 'allows multiple rules per policy - 1', ->
    req =
      _profile:
        my:
          entitlements: ['user', 'admin']
        user: 'cjcoff'

      _route:
        'user-profile-policy': [
            pathOperand: 'my.entitlements'
            operator: 'contains'
            valueOperand: 'admin',
            pathOperand: 'user'
            operator: 'equals'
            valueOperand: 'cjcoff'
        ]
    next = sinon.stub()

    userProfilePolicy(req, res, next)

    expect(next.called).to.be.true

  it 'allows multiple rules per policy - 2', ->
    req =
      _profile:
        my:
          entitlements: ['user', 'admin']
        user: 'cjcoff'

      _route:
        'user-profile-policy': [
            {
              pathOperand: 'my.entitlements'
              operator: 'contains'
              valueOperand: 'admin'
            }
            {
              pathOperand: 'user'
              operator: 'equals'
              valueOperand: 'dbtand'
            }
        ]
    next = sinon.stub()

    userProfilePolicy(req, res, next)

    expect(next.called).to.be.true
