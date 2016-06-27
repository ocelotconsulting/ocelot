var assert = require("assert"),
    response = require('../src/response');

describe('response', function () {
    it('sends a response', function () {
        var res = {};
        var responseText = null;
        var ended = false;

        res.write = function(str){
            responseText = str;
        };

        res.end = function(){
            ended = true;
        };
        res.setHeader = function(header){};

        response.send(res, 302, "abc");

        assert.equal(responseText, "abc");
        assert.equal(res.statusCode, 302);
        assert.equal(ended, true);
    });

    it('does not send payload when nothing to write', function () {
        var res = {};
        var responseText = null;
        var ended = false;

        res.write = function(str){
            responseText = str;
        };

        res.end = function(){
            ended = true;
        };
        res.setHeader = function(header){};

        response.send(res, 302);

        assert.equal(responseText, null);
        assert.equal(res.statusCode, 302);
        assert.equal(ended, true);
    });
});
