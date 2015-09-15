exports.request = function (px, req, res, url) {
    req.url = url.path;

    px.web(req, res, {
        // todo: protocol requires slashes
        target: url.protocol + "//" + url.host
    });
};
