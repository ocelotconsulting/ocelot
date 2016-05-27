backend = require '../src/backend/facade'
agent = (require '../src/http-agent').getAgent()
backend.init()

setTimeout () =>
  routesAsync = backend.getRoutes()
  serviceHostsAsync = backend.getHosts()

  getHosts = (hosts, services, allHosts) ->
    flattenServicesAndHosts = (hosts, services, allHosts) ->
        (services or []).reduce (prev, serviceName) ->
          prev.concat ((allHosts[serviceName] or []).map (service) -> service.url)
        , (hosts or [])

    flattenServicesAndHosts hosts, services, allHosts
    .map (host, index) -> host

  serviceHostsAsync.then (serviceHosts) ->
    routesAsync.then (routes) =>

      routes.forEach (route) ->
        hosts = getHosts(route.hosts, route.services, serviceHosts)
        route.hosts = hosts
        delete route.services
        id = route.route
        delete route.route
        console.log 'migrating', id

        agent.get "https://ocelot-couch.velocity-np.ag/routes/#{encodeURIComponent(id)}"
        .set 'Authorization', 'Basic YmFib3U6c2VycGVudGluZQ=='
        .set 'alt-auth', 'Bearer 7ktvCxrPLPucyqe0laXHudxOJcbC'
        .set 'Accept', 'application/json'
        .then (res) ->
          "?rev=#{res.body._rev}"
        .catch (e) ->
          ''
        .then (q) ->
          agent.put "https://ocelot-couch.velocity-np.ag/routes/#{encodeURIComponent(id)}#{q}", route
          .set 'Authorization', 'Basic YmFib3U6c2VycGVudGluZQ=='
          .set 'alt-auth', 'Bearer 7ktvCxrPLPucyqe0laXHudxOJcbC'
          .then ->
            console.log 'saved', id
          .catch (e) ->
            console.log 'could not save', id, e

  .catch (err) ->
    console.log err

, 2000
