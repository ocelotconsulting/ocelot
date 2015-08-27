var postman = require('./postman'),
    redirect = require('./redirect'),
    cookies = require('./cookies');

function tryToken(req, route) {
    var refreshToken = cookies.parse(req)[route['cookie-name'] + '_rt'];
    var refreshQuery = 'grant_type=refresh_token&refresh_token=' + refreshToken;

    return postman.post(refreshQuery, route);
}

exports.token = function (req, res, route) {
    tryToken(req, route).then(function (result) {
        cookies.set(res, route, result);
        redirect.refreshPage(req, res);
    }, function (error) {
        console.log(error);
        redirect.toAuthServer(req, res, route);
    });
};
