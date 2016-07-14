transformer = (logData) ->
  transformed = Object.assign {}, logData.meta
  transformed['timestamp'] = new Date().toISOString();
  transformed.message = logData.message;
  transformed.severity = logData.level;
  transformed;

module.exports = transformer
