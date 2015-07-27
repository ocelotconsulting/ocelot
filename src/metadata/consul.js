var _ = require("underscore");

exports.interpretRoutes = function (raw) {
    var regex = /routes\/(.+)/;
    return _.filter(_.map(raw, function (obj) {
        try {
            var decoded = JSON.parse(new Buffer(obj.Value, 'base64').toString('utf8'));
            var match = regex.exec(obj.Key);
            decoded["route"] = match[1];
            return decoded;
        } catch (e) {
            return null;
        }
    }), function (obj) {
        return obj !== null;
    });
};

exports.interpretServices = function (raw) {
    var regex = /services\/(.+)\/(.+)/;
    var filtered = _.filter(_.map(raw, function (obj) {
        if (regex.test(obj.Key)) {
            try {
                var decoded = JSON.parse(new Buffer(obj.Value, 'base64').toString('utf8'));
                var match = regex.exec(obj.Key);
                decoded["name"] = match[1];
                decoded["id"] = match[2];
                return decoded;
            } catch (e) {
                return null;
            }
        } else {
            return null
        }
    }), function (obj) {
        return obj !== null;
    });
    return _.groupBy(filtered, 'name');
};
