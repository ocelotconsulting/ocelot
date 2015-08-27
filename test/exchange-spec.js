var assert = require("assert"),
    exchange = require("../src/auth/exchange"),
    postman = require("../src/auth/postman"),
    sinon = require("sinon");

describe('exchange', function () {
    it('validates token and sets up a redirect to original url encoded in state', function () {
        var resolveIt;
        var rejectIt;
        var thisQuery;
        var thisRoute;
        var req = {};
        var res = {};
        var route = {};

        var promise = new Promise(function(resolve, reject){
            resolveIt = resolve;
            rejectIt = reject;
        });

        sinon.stub(postman, "post", function (query, route) {
            thisQuery = query;
            thisRoute = route;
            return promise;
        });

        req.url = "www.monsanto.com/abc";
        exchange.code(req, res, route);

    });

    afterEach(function () {
        restore(postman.post);
    });

    function restore(mockFunc) {
        if (mockFunc.restore) {
            mockFunc.restore();
        }
    }
});