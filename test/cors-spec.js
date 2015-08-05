var assert = require("assert"),
    cache = require('../src/metadata/cache'),
    cors = require('../src/cors');

describe('cors', function () {
    describe('preflight', function () {
        it('is in effect when origin header present, req method present,  and is options request', function () {
            var req = {};
            req.headers = {};
            req.headers.origin = "abc.monsanto.com";
            req.headers['access-control-req-method'] = "PUT";
            req.method = "OPTIONS";

            assert.equal(cors.preflight(req), true);
        });

        it('is not in effect if not options method', function () {
            var req = {};
            req.headers = {};
            req.headers.origin = "abc.monsanto.com";
            req.headers['access-control-req-method'] = "PUT";
            req.method = "GET";

            assert.equal(cors.preflight(req), false);
        });

        it('is not in effect if origin not set', function () {
            var req = {};
            req.headers = {};
            req.headers['access-control-req-method'] = "PUT";
            req.method = "OPTIONS";

            assert.equal(cors.preflight(req), false);
        });

        it('is not in effect if req method not set', function () {
            var req = {};
            req.headers = {};
            req.headers.origin = "abc.monsanto.com";
            req.method = "OPTIONS";

            assert.equal(cors.preflight(req), false);
        });
    });

    describe('headers', function () {

        var req, res = {};

        it('sets standard ac origin headers for cors', function () {
            req.headers.origin = "abc.monsanto.com";

            cors.setCorsHeaders(req, res);

            assert.equal(res['Access-Control-Allow-Origin'], "abc.monsanto.com");
            assert.equal(res['Access-Control-Max-Age'], "1728000");
            assert.equal(res['Access-Control-Allow-Credentials'], "true");
        });

        it('sets origin to * if empty', function () {
            req.headers.origin = "";

            cors.setCorsHeaders(req, res);

            assert.equal(res['Access-Control-Allow-Origin'], "*");
        });

        it('sets allowed headers if required', function () {
            req.headers['access-control-req-headers'] = "abc";

            cors.setCorsHeaders(req, res);

            assert.equal(res['Access-Control-Allow-Headers'], "abc");
        });

        it('sets req method header if required', function () {
            req.headers['access-control-req-method'] = "abc";

            cors.setCorsHeaders(req, res);

            assert.equal(res['Access-Control-Allow-Methods'], "abc");
        });

        beforeEach(function () {
            req = {};
            req.headers = {};

            res = {};
            res.setHeader = function (header, value) {
                this[header] = value;
            };
        });
    });
});