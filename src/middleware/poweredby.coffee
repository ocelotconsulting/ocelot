module.exports = (req, res, next) ->
  res.setHeader 'powered-by', 'ocelot'
  next()
