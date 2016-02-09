assert = require 'assert'
sinon = require 'sinon'
require 'sinon-as-promised'
headers = require '../src/auth/headers'
postman = require '../src/auth/postman'
exchange = require '../src/auth/exchange'
validate = require '../src/auth/validate'

describe 'validate', ->
    {postmanMock} = {}

    beforeEach ->
        postmanMock = sinon.stub postman, 'postAs'

    afterEach ->
        postmanMock.restore()

    it 'resolves if no required auth', (done) ->
        req = {}
        route = {}
        route['require-auth'] = false
        validate.authentication(req, route).then ((auth) ->
            done()
        ), (auth) ->
            done('auth failed!')


