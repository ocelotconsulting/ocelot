exports.parse = function(req){
    console.log("parsing cookies 1  !!!!!!!!!!!!!");
    var list = {},
        rc = req.headers.cookie;

    console.log("parsing cookies 2  !!!!!!!!!!!!!");

    rc && rc.split(';').forEach(function (cookie) {
        var parts = cookie.split('=');
        list[parts.shift().trim()] = decodeURI(parts.join('='));
    });

    console.log("parsing cookies 3  !!!!!!!!!!!!!");

    return list;
};