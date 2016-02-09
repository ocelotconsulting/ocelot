assert = require 'assert'
clientWhitelist = require '../src/auth/client-whitelist'

describe 'client whitelist', ->
  it 'accepts requests that are authenticated but not whitelisted', ->
    authentication = {client_id: 'valid_client'}
    route = {'client-whitelist': ['invalid_client']}

    assert.equal(clientWhitelist.accept(route, authentication), true)

  it 'does not accept if there is no whitelist', ->
    authentication = {client_id: 'valid_client'}
    route = {'client-whitelist': []}

    assert.equal(clientWhitelist.accept(route, authentication), false)

  it 'does not accept if there no client to check against', ->
    authentication = {}
    route = {'client-whitelist': ['some-client']}

    assert.equal(clientWhitelist.accept(route, authentication), false)

  it 'does not accept if authentication does not exist', ->
    route = {'client-whitelist': ['some-client']}

    assert.equal(clientWhitelist.accept(route), false)
