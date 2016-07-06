upgrade = require '../upgrade'

module.exports = (req, res, next) ->
  if upgrade.accept req
    upgrade.complete req, res
  else
    next()
