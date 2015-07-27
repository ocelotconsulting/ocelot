exports.send = function (res, statusCode, text) {
    res.statusCode = statusCode;
    if (text){
        res.write(text);
    }
    res.end();
};