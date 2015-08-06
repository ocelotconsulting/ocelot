# The Ocelot Router

## About
The Ocelot router is a lightweight reverse proxy written in Node.js and it serves several purposes.
1. It allows blue/green route switching. 
2. Reads configuration via configurable REST endpoints, so its good for hot deployments
3. Each route has a different configuration
4. Allows authentication hooks for Ping OAuth validation, bearer or cookie based. Cookie based authentication redirects browsers to Ping login page.
5. Enables sending user and client headers to app based on requirements. This allows backwards compatibility with WAM headers.

## Why Node.js?
The Node.js router is super lightweight and fast. The NPM repo already has widely used reverse proxy dependencies, the one I chose was https://www.npmjs.com/package/http-proxy.

## How to run the code
`npm start` or `node src/server.js`

## How to release
I'm using Docker to release the code.  To build the latest image run `docker build -t dockerc01.monsanto.com:5000/ocelot:<version goes here> .`

## How to configure
Ocelot uses npm config https://www.npmjs.com/package/config to read basic router configuration from config/default.json. 
The router then uses the endpoints in the router config to connect to a backend key value store to load route specific configuration.
To supply the router with a different default config, the best way is to just set an env var called NODE_CONFIG, which will override 
the json contained in the config file.  The env var contains the actual json config, not a file path.

Therefore, to run the router with docker and a custom config you might do something like...

`sudo docker run -d --restart always -p 80:8080 

-e NODE_CONFIG='{
    "backend": {
        "consul": {
            "routes": "http://stludockersbx01.monsanto.com:8500/v1/kv/np-routes?recurse",
            "services": "http://stludockersbx01.monsanto.com:8500/v1/kv/np-services?recurse"
        }
    },
    "authentication": {
        "ping": {
            "validate": {
                "client": "TPS_VALIDATOR",
                "secret": "TPS_VALIDATOR"
            },
            "host": "https://test.amp.monsanto.com"
        }
    },
    "route": {
        "host": "auto"
    }
}'

--name ocelot-np dockerc01.monsanto.com:5000/ocelot:1.3`

## Where does ocelot run?
Ocelot is currently deployed to stludockerprd01 - 03.  The first node is mapped to pd-tools-np domain, the second two nodes are mapped to the pd-tools domain.

## How does it route?
Ocelot takes the URL path (no host) and finds a key in the route endpoint that best matches the path.  The key that best matches
contains config information, including which backend endpoints or 'services' to load balance the request over.
