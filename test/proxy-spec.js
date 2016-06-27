var assert = require("assert"),
    proxy = require('../src/proxy');

describe('proxy request', function () {
    it('sets req url and proxy target', function () {
        var px = {};
        var req = {};
        var res = {};
        var url = {};

        url.path = "app1";
        url.protocol = "http:";
        url.host = "testy";

        px.web = function(req, res, config){
            this['req'] = req;
            this['res'] = res;
            this['config'] = config;
        };

        proxy.request(px, req, res, url);

        assert.equal(px.req, req);
        assert.equal(px.res, res);
        assert.equal(px.config.target, "http://testy");
        assert.equal(px.req.url, url.path);
    });
});
