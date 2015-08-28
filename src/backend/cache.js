var consul = require('./consul.js'),
    config = require('config');

var backend;

exports.initCache = function () {
    if (config.has('backend.consul')) {
        backend = consul;
    }
    else {
        throw "no backend found in configuration";
    }
    backend.initCache();
};

exports.getRoutes = function () {
    return backend.getRoutes();
};

exports.getServices = function () {
    return backend.getServices();
};

exports.reloadData = function(){
    return backend.reloadData();
};
