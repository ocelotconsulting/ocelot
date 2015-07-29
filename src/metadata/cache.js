var consul = require('./consul.js'),
    config = require('config');

var backend;

exports.initCache = function initCron() {
    if (config.has("backend.consul") ) {
        backend = consul;
    }
    else{
        throw "no backend found in configuration";
    }
    backend.initCache();
};

exports.getRoutes = function (url) {
    return backend.getRoutes();
};

exports.getServices = function (url) {
    return backend.getServices();
};
