assert = require 'assert'
tokenInfo = require '../../src/auth/token-info'

describe 'token info', ->
    it 'accepts if req url path ends with auth-token-info', ->
      assert tokenInfo.accept({url:'some/path/auth-token-info?q=blah'}) == true

    it 'does not accept if auth-token-info found in query', ->
      assert tokenInfo.accept({url:'some/path?q=auth-token-info'}) == false

    it 'does not accect if does not end in auth-token-info', ->
      assert tokenInfo.accept({url:'some/auth-token-info/path'}) == false
