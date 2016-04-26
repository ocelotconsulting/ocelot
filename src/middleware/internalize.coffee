module.exports = (req, res, next) ->
  req._internal = true
  next()
