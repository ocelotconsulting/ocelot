var postman = require('./postman'),
    redirect = require('./redirect'),
    cookies = require('../cookies'),
    headers = require('./headers');

exports.token = function (req, res, route) {
    tryRefresh(req, route).then(function (result) {
        headers.setAuthCookies(res, route, result);
        redirect.refreshPage(req, res);
    }, function (error) {
        console.log(error);
        redirect.toAuthServer(req, res, route);
    });
};

function tryRefresh(req, route) {
    var refreshToken = cookies.parse(req)[route['cookie-name'] + '_rt'];
    var refreshQuery = 'grant_type=refresh_token&refresh_token=' + refreshToken;

    return postman.post(refreshQuery, route);
}
