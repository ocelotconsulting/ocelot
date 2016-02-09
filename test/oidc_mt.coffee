#oidc = require '../src/auth/oidc'
#
#describe 'oidc_mt', ->
#  it 'validates oidc', (done) ->
#    my_oidc = 'eyJhbGciOiJSUzI1NiIsImtpZCI6IndrYWNuIn0.eyJzdWIiOiJjamNvZmYiLCJ6b25laW5mbyI6InJlZ2lvbiIsIndlYnNpdGUiOiJ3ZWJzaXRlIiwibmlja25hbWUiOiJDSFJJU1RPUEhFUiIsIm1pZGRsZV9uYW1lIjoiTWlkZGxlIG5hbWUiLCJlbWFpbF92ZXJpZmllZCI6ZmFsc2UsImxvY2FsZSI6IkxvY2FsZSIsInByZWZlcnJlZF91c2VybmFtZSI6ImNqY29mZiIsImdpdmVuX25hbWUiOiJDSFJJU1RPUEhFUiIsInVwZGF0ZWRfdGltZSI6InVwZGF0ZWRfdGltZSIsInBpY3R1cmUiOiJQaWN0dXJlIiwiQXBwbGljYXRpb25FbnRpdGxlbWVudHMiOiJBV1MtTW9uSVRTQS1Qcm9kLUFkbWluU1NPIiwiZW1haWwiOiJjaHJpc3RvcGhlci5qLmNvZmZtYW5AbW9uc2FudG8uY29tIiwiY24iOiJDSkNPRkYiLCJuYW1lIjoiQ0hSSVNUT1BIRVIiLCJiaXJ0aGRhdGUiOiJCaXJ0aGRhdGUiLCJnZW5kZXIiOiJnZW5kZXIiLCJmYW1pbHlfbmFtZSI6IkNPRkZNQU4iLCJ1c2VyX2lkIjoiQ0pDT0ZGIiwiZGlzcGxheU5hbWUiOiJDb2ZmbWFuLCBDaHJpc3RvcGhlciBKIiwiZ3JvdXAiOiJub3QtYXZhaWxhYmxlIiwicHJvZmlsZSI6InByb2ZpbGUiLCJhdWQiOiJPQ0VMT1QtVUkiLCJqdGkiOiJaeEtHZlpSN3pqUk81N2tBN3huQUlGIiwiaXNzIjoiaHR0cHM6XC9cL3Rlc3QuYW1wLm1vbnNhbnRvLmNvbSIsImlhdCI6MTQ1NDk5NDE4NiwiZXhwIjoxNDU1MDAxMzg2fQ.CwtkX94UEUQWHl50pH2ygzQHmBefTYXmzi0b6y7632oajNTot39XH4nj591o-ARU6JBLqlcluvnLVmp6kAt1DnL1Jk_NddOEvA09KVJfzO0epBitaa0ZGZq2tYn4L2jwhw7QNFdN_LD2RtbtXm9rWIdjHdhwMe4Wh6cqcaeHMhfrp6Kuw35p8TobxR9P5rX-QNLmiKuEHJYY3BJSg2eV2EMlQOLtHaWmyOze51cr4gvM_n502F5_olRr8UR_si8FJdx9Lk5j5aW7DvJq7uREnEJsGEX9I2ngujYc5R4YlP4jldj_eFgpftpNCDFZGj0oZzsGVourZdM4Rkj8f6SEKQ'
#    oidc.init()
#    setTimeout () ->
#      try
#        oidc.validate my_oidc
#        .then -> console.log 'success!'
#        .catch (e) -> console.log 'fail! ', e
#        done()
#      catch e
#        console.log e
#        done()
#    , 1000
