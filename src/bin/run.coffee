config = require 'config'
log = require '../log'

exampleConfig = """
  [
      {
        "route": "ocelot.localhost/echo",
        "hosts": ["http://localhost:3005/"],
        "require-auth": true,
        "user-header": "user-id",
        "client-header": "client-id",
        "cookie-name": "myCookie",
        "client-id": "TPS_TEST",
        "client-secret": "TPS_TEST",
        "user-profile-enabled": true
      }
    ]
"""

fs = require 'fs'
configPath = if process.env.OCELOT_CONFIG_PATH
    process.env.OCELOT_CONFIG_PATH
  else
     home = process.env.HOME or '/'
     home + '/.ocelot_routes'

fs.stat configPath, (err, stats) ->
  staticRouteConfig = null
  if err or not stats.isFile
    log.debug 'No static route file found at', configPath
  else
    try
      staticRouteConfig = JSON.parse(fs.readFileSync(configPath, 'utf8'));
      process.env.OCELOT_ROUTES=JSON.stringify(staticRouteConfig, null, 2)
      log.debug 'Found static routes configuration'
    catch
      log.debug 'Could not read static route file'

  if process.env.NODE_ENV == 'bin' and not process.env.NODE_CONFIG and not staticRouteConfig
    log.debug 'Example route config file: '
    console.log exampleConfig
  else if not process.env.NODE_ENV and not process.env.NODE_CONFIG
    log.error 'Make sure the environment variable NODE_ENV or NODE_CONFIG is set'
  else
    require '../server'
