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
