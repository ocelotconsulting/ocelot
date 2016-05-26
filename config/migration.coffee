module.exports =
  backend:
    provider: "consul"
    hosts: "https://ocelot-consul.velocity-np.ag/v1/kv/services/"
    routes: "https://ocelot-consul.velocity-np.ag/v1/kv/routes/"
