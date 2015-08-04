exports.request = function (px, req, res, url) {
    req.url = url.path;

    px.web(req, res, {
        target: url.protocol + "//" + url.host
    });
};
