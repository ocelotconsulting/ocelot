fs = require 'fs'
sinon = require 'sinon'
xml2js = require 'xml2js'
require 'sinon-as-promised'
should = require('chai').should()
{findWAMTokenInXML} = require '../src/backend/wam'

exampleXml = fs.readFileSync './test/example.xml', encoding: 'utf8'

describe 'wam', ->
    describe 'findWAMTokenInXML', ->
        {parsedXml} = {}

        beforeEach ->
            new Promise (resolve, reject) ->
                xml2js.parseString exampleXml, (error, result) ->
                    parsedXml = result
                    if error then reject error else resolve()

        it 'returns token', ->
            findWAMTokenInXML(parsedXml).should.equal 'foobar'

        it 'returns undefined if token is not in expected path', ->
            xml = 's:Envelope':
                    's:Body': []

            should.not.exist findWAMTokenInXML(xml)
