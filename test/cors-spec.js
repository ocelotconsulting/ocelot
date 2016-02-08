var assert = require("assert");
var cors = require('../src/cors');

describe('cors', function () {
    describe('shortCircuit', function () {
        describe('is not in effect when', function(){
            it('request method is not options', function () {
                var req = {};
                req.headers = {};
                req.headers.origin =  "abc.monsanto.com";
                req.headers['access-control-request-method'] = "PUT";
                req.method = "GET";

                assert.equal(cors.shortCircuit(req), false);
            });

            it('origin is not set', function () {
                var req = {};
                req.headers = {};
                req.headers['access-control-request-method'] = "PUT";
                req.method = "OPTIONS";

                assert.equal(cors.shortCircuit(req), false);
            });

            it('request method is not set', function () {
                var req = {};
                req.headers = {};
                req.headers.origin = "abc.monsanto.com";
                req.method = "OPTIONS";

                assert.equal(cors.shortCircuit(req), false);
            });

            it('origin is null string and referrer is trusted', function () {
                var req = {};
                req.headers = {};
                req.headers.origin = "null";
                req.method = "GET";
                req.headers.referer = "http://abc.monsanto.com/blah";

                assert.equal(cors.shortCircuit(req), false);
            });
        });

        describe('is in effect when', function(){
            it('cors preflight is detected', function () {
                var req = {};
                req.headers = {};
                req.headers.origin = "abc.monsanto.com";
                req.headers['access-control-request-method'] = "PUT";
                req.method = "OPTIONS";

                assert.equal(cors.shortCircuit(req), true);
            });

            it('origin is from an untrusted domain', function () {
                var req = {};
                req.headers = {};
                req.headers.origin = "abc.untrusted.com";
                req.method = "GET";

                assert.equal(cors.shortCircuit(req), true);
            });

            it('origin is null string and referrer is untrusted', function () {
                var req = {};
                req.headers = {};
                req.headers.origin = 'null';
                req.method = "GET";
                req.headers.referer = "http://abc.untrusted.com/blah";

                assert.equal(cors.shortCircuit(req), true);
            });
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

        it('cors is enabled even for unspecified ports', function () {
            req.headers.origin = "http://abc.monsanto.com:8080";

            cors.setCorsHeaders(req, res);

            assert.equal(res['Access-Control-Allow-Origin'], "http://abc.monsanto.com:8080");
            assert.equal(res['Access-Control-Max-Age'], "1728000");
            assert.equal(res['Access-Control-Allow-Credentials'], "true");
        });

        it('sets allowed headers if required', function () {
            req.headers.origin = "abc.monsanto.com";
            req.headers['access-control-request-headers'] = "abc";

            cors.setCorsHeaders(req, res);

            assert.equal(res['Access-Control-Allow-Headers'], "abc");
        });

        it('sets req method header if required', function () {
            req.headers.origin = "abc.monsanto.com";
            req.headers['access-control-request-method'] = "abc";

            cors.setCorsHeaders(req, res);

            assert.equal(res['Access-Control-Allow-Methods'], "abc");
        });

        it('if the origin is not from an allowed domain, allow origin is not set', function () {
            req.headers.origin = "abc.deere.com";

            cors.setCorsHeaders(req, res);

            assert.equal(typeof res['Access-Control-Allow-Origin'] == 'undefined', true);
        });

        it('not set without subdomain or exact match', function () {
            req.headers.origin = "http://monsanto.com";

            cors.setCorsHeaders(req, res);

            assert.equal(typeof res['Access-Control-Allow-Origin'] == 'undefined', true);
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