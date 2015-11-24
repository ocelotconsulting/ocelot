assert = require 'assert'
config = require 'config'
sinon = require 'sinon'
parseCookies = require '../src/parseCookies'

describe 'parse cookies', ->

  it 'double cookie names takes first value', ->
    req = {headers: {cookie: "this=that; this=that2"}}
    assert.deepEqual parseCookies(req),
      "this": "that"



