# The Ocelot Router

## About
The Ocelot router is a lightweight reverse proxy written in Node.js.  It allows you to 
1. Dynamically change routes without restarting the proxy, which is useful for blue/green deployments and service discovery. 
2. Rewrite URLs using regular expressions
3. Easily enable CORS.
4. Validate Ping OAuth tokens either in the Authorization header or in a custom Cookie
5. Notify your application of the calling user and client IDs using user defined header names
6. Redirect unauthenticated requests to Ping by enabling a Cookie flow.
7. Route based on subdomain or root context.

## Why Node.js?
The Node.js router is super lightweight and fast. The NPM repo already has widely used reverse proxy dependencies, the one I chose was https://www.npmjs.com/package/http-proxy.


## What is the backend?
Right now Ocelot uses a consul standalone node or cluster as a key value store.  There are plans to support multiple backends.

## How to configure
Ocelot uses npm config https://www.npmjs.com/package/config to read basic router configuration from config/default.json. 
The router then uses the endpoints in the router config to connect to a backend key value store to load route specific configuration.
To supply the router with a different default config, the best way is to just set an env var called NODE_CONFIG, which will override 
the json contained in the config file.  The env var contains the actual json config, not a file path.

## Where does ocelot run?
Ocelot is currently deployed to stludockerprd01 - 03.  The first node is mapped to pd-tools-np domain, the second two nodes are mapped to the pd-tools domain.  

## How does it route?
Ocelot takes the host header and finds a key in the route endpoint that matches the subdomain.  If none exists,
it tries to find a route that best matches the path.  The key that best matches
contains config information, including which backend endpoints to load balance the request over.

## How to run in Docker

This is an example configuration, using Consul as a backend

```
sudo docker run -d --restart always -p 80:8080 -p 81:8081 -e NODE_CONFIG='{
  "backend": {
    "consul": {
      "routes": "http://consulhost/v1/kv/routes",
      "hosts": "http://consulhost/v1/kv/services"
}
  },
  "jwks": {
    "url": "https://test.amp.monsanto.com/pf/JWKS"
  },
  "authentication": {
    "ping": {
      "validate": {
        "client": "pingclientid",
        "secret": "pingsecret"
      },
      "host": "https://test.amp.monsanto.com"
    }
  },
"default-protocol": "https",
"enforce-https": true,
"cors-domains": ["velocity.ag", "https://velocity.ag", "monsanto.com", "threega.com", "localhost", "velocity-np.ag", "https://velocity-np.ag"]
}' --name ocelot docker-registry.threega.com/ocelot:1.19
```