# The Ocelot Router

The Ocelot router is a lightweight proxy, based on the popular node package http-proxy. Ocelot adds in support for OAuth, CORS, redirects to https, websockets, service discovery and hot reload of Routing configuration. Ocelot has cookie support for browsers, using OAuth authorization code flow to redirect users to an authorization endpoint. It can also be hooked into a profile system, adding headers for user-id and user-profile.

## Configuring Ocelot
Router settings are read by using the NPM 'config' package, so you usually set them by defining one or more environment variables. See the environment variable section for more information.

#### Router settings
Since router settings are read with the 'config' package, it can be provided in a variety of formats. Typically JSON and YAML are used.

* **log-level (String):** The level at which to output logs. Usually set to "debug"
* **cors-domain (Array of Strings):** Ocelot will try to handle CORS requests. Use this list as a domain whitelist for which to allow CORS requests from. You can specify something that matches the Origin header exactly (http://abc.mydomain.com:8080) but it will allow any port by default (http://abc.mydomain.com) or you can just whitelist the top level domain (mydomain.com).
* **enforce-https (Boolean):** Ocelot will try to redirect to https if accessed over http. I usually terminate SSL before getting to Ocelot (like in an AWS ELB) so the original protocol can be found in the x-forwarded-proto.
default-protocol: This is the protocol you want to use to redirect Browsers back to Ocelot after redirecting to the login page.
* **api-clients (Array of Strings):** The OAuth client IDs that are allowed to hit the Ocelot APIs.
* **authentication (Object):**
  * **validation-client (String):** The client ID that is used to validate tokens
  * **validation-secret (String):** The client secret used to validate tokens
  * **token-endpoint (String):** The OAuth token endpoint URL
  * **auth-endpoint (String):** The OAuth auth endpoint URL
  * **profile-endpoint (String):** If a user can be determined, load the user details by using this URL template. Use $userId and $appId to format the URL appropriately.
* **backend (Object):**
  * **provider (String):** The type of backend you are using
  * **other properties (?):** Each backend has other config props depending on the provider

Example (local.coffee):
```coffee
module.exports =

  authentication:
    'validation-client': "MY_VALIDATOR_CLIENT"
    'validation-secret': "THIS_IS_NOT_A_REAL_SECRET"
    'token-endpoint': "https://authserver.local/as/token.oauth2"
    'auth-endpoint': "https://autherserver.local/as/authorization.oauth2"
    'profile-endpoint': 'https://profileapi.local/users/$userId?fields=id,firstName,lastName,entitlements,email,fullName&apps=$appId'

  'cors-domains': ["localhost"]
  'api-clients': ["OCELOT-UI"]
  'default-protocol': "http"
  'enforce-https': false
  'cors-domains': ["localhost", "mydomainiown.com", "https://someothertrustedcomain.com"]
  'log-level': "debug"

  backend:
    provider: "couch"
    url: "http://127.0.0.1:5984"
```

## Backends
The backend is a property in the router config that specifies the datastore where route and service configurations are held. Each datastore is a little different and some assume seperate 'tables' or 'collections' called specifically 'routes' or 'hosts' while others ask for a URL or file path for routes and hosts seperately. 

* **Consul:** Consul backend has two properties, routes and hosts. Both are URLs to a key value location. Ocelot slaps /?recurse to the endpoints and grabs all kvs under each every 30 seconds. The 'hosts' property refers to the service hosts, as referenced by each route's service property. 
* 
  * Example:
  ```
  backend:
   provider: "consul"
   routes: "http://consul.local:8500/v1/kv/routes"
   hosts: "http://consul.local:8500/v1/kv/hosts"
  ```

* **Couch:** Couch has one property, url. Couch, unlike the consul backend, expects to find two databases, routes and services. Each database is expected to have a design document named the same as the database with a view called 'all'. Ocelot executes each view every 30 seconds. The 'services' database refers to the service hosts, as referenced by each route's service property. 
  * Example:
  ```
  backend:
   provider: "couch"
   url: "http://127.0.0.1:5984"
  ```

* **Redis:** Redis has two properties, host and port. The backend will then use hgetall every 30 seconds on the hash routes and hosts every 30 seconds. The 'hosts' hash refers to the service hosts, as referenced by each route's service property. I personally don't use Redis anymore because it seemed to be a bit unstable in AWS.
  * Example:
  ```
  backend:
   provider: "redis"
   host: "http://127.0.0.1"
   port: 6397
  ```

* **Env:** Reads the route config directly from the environment. This does not support using service hosts, as service discovery isn't possible without a real backend. This backend requires no configuration, simply set an environment variable called OCELOT_ROUTES to be what the contents of the route database should be.
 ```
  OCELOT_ROUTES=[{...see the route configuration example...}]
 ```

* **Flat File:** Reads the route config directly from a file. This does not support using service hosts, as service discovery isn't possible without a real backend. This backend requires no configuration, simply set an environment variable called OCELOT_ROUTES_PATH which is the path where the route config file lives. This backend will automatically look for a file called .ocelot_routes in your home directory by default.

#### Route configuration
* **capture-pattern (String):** A regular expression used to 'capture' the incoming path. It defaults to '(.*)' to capture the entire path but can be set to '/something(.*)' to strip 'something' off something before proxying to the backend. Path manipulation can be helpful, but it can really screw up UIs. This is not a common property to set.
* **rewrite-pattern (String):** The companion to capture-pattern. It is used to create the proxy path by using placeholders to refer to the capture regex capture groups and is usually defaulted to $1. You can add 'something' to the path by setting this to '/something$1'. Path manipulation can be helpful, but it can really screw up UIs. This is not a common property to set.
* **services (Array of Strings):** This is used for service discovery. When using service discovery, multiple services should be able to register themselves without updating the route record directly to avoid conflicts. Services are collections of hosts stored in the backend and the service name is simply the key referring to a particular collection of hosts. 
* **require-auth (Boolean)**: Validation of authorization token is required before proxying. OAuth tokens are by default expected to be in the format 'Authorization: Bearer <token>'.
* **client-whitelist (Array of Strings):** Which OAuth client IDs are allowed to hit the Ocelot API. This should be locked down to Ocelot UI and service discovery endpoints. If left blank, allows all clients (danger)!
* **user-header (String):** When the user can be determined by successful validation of the OAuth token, the user's ID will be added to the proxied request in an HTTP header with this name.
client-header (String): When the calling client (application) can be determined by successful validation of the OAuth token, the client's ID will be added to the proxied request in an HTTP header with this name.
* **custom-headers (?):** Add these static proxy headers to the request.
ent-app-id (String): When user-profile-enabled, use this entitlement app ID to replace $appId in the profile endpoint to load the user's profile. This is optional and only required if the profile endpoint needs to know what application the user belongs to.
* **user-profile-enabled (Boolean):** When a user can be determined based on validation of the OAuth token, call the profile endpoint to get the user's profile. Add the user-profile header with the result, usually JSON formatted.
* **elevated-trust (Boolean):** Normally the user-header is protected in that it is non-spoofable and cannot be send into Ocelot; it can only come from validation of the OAuth token. Sometimes you want trusted clients to be able to pass in the user and for Ocelot to treat that the same as if it came from the OAuth token. Use this flag to allow this flow. This can be a pretty dangerous setting, so use it with care.
internal (Boolean): Ocelot runs the proxy on two ports. The second port is considered the internal traffic port. Set internal to true if you only want it accessible from the internal port.
* **hosts (Array of Strings):** The hosts array is used to determine what the backend hosts are that we are proxying to. It is similar to the service array, but instead of a reference to another collection of URLs by name these are the actual URL values. This is simpler than using the services property and usually they are not used together.
* **cookie-name (String):** Used in conjunction with the require-auth property, this property enables UI support for the route. When the cookie-name is set Ocelot will check incoming requests first for Authorization bearer tokens but will fall back to checking for this cookie. If the token cannot be found Ocelot redirects to the auth-endpoint URL with a redirect back to the current URL /receive-auth-token. The purpose of this is to use the auth flow in OAuth to generate a token, which will then be set back on the browser with this cookie name. When using this property both client-id and client-secret are required.
* **client-id (String):** The OAuth client id used to exchange the user's login code for a token.
* **client-secret (String):** The OAuth client secret used to exchange the user's login code for a token.
* **scope (String):** An optional property usually used to enable OpenId
* **cookie-path (String):** Overrides the default cookie path, which is set to the path of the route.
* **cookie-domain (String):** Overrides the default cookie domain, which is set to the domain of the route.

Example environment variable backend:
```javascript
[
    {
      "route": "ocelot.localhost/echo",
      "hosts": ["http://localhost:3005/"],
      "require-auth": true,
      "user-header": "user-id",
      "client-header": "client-id",
      "cookie-name": "myCookie",
      "client-id": "TEST_CLIENT",
      "client-secret": "THIS_IS_NOT_REAL",
      "user-profile-enabled": true,
      "client-whitelist": ["TEST_CLIENT"]
    }
  ]
```

## Hosts vs. Service Hosts
Backend host locations can be configured for each route using the services property or the hosts property. Both lists get merged together at run time for routing purposes. The difference is simply the data structure; the service list can be shared between routes and allows for easier service registration. When updating the route, you have to grab the entire record and update it, which may conflict with someone else doing the same thing. Therefore, use the 'hosts' property for simplicity and 'services' for a more advanced service discovery mechanism. Both get thrown together as the available hosts, so it is possible to use both but it is not recommended.

#### Service configuration
Service configuration key is usually /serviceName/serviceId. The serviceId does not matter normally, and the serviceName is what is referred to in the route's service array. The idea is that a registrar can PUT the service without needing to grab and update a collection that other people might need to write to. This structure can be confusing, in which case just use the host property to set URLs on the route directly.

```
url: The backend URL!
```

## Technical Overview
Ocelot is an Express application, where most of the code is just a chain of middleware. There are a few defined endpoints, but only for the Ocelot API which runs on a different port than the proxy. Here is a list of middleware in the order in which they run and what they do.

#### Middleware
* **Promethus:** Ocelot keeps track of a few metrics, like requests per/second. This middleware puts the time on the current request and registers function callbacks for when the request is completed to register how long the request took.
*  **Powered By:** Adds a powered-by HTTP header. Its actually useful to know that your requests are hitting Ocelot. Why not set the x-powered-by header? Because x- is not a standard.
*  **Cors:** Respond property to CORS requests. CORS domains should be whitelisted in the Ocelot config. The CORS code handles preflights by responding directly without calling the backend. Ocelot never responds with AC-ALLOW-ORIGIN: *. It does allow custom headers and supports credentials.
*  **Upgrade:** Upgrade is not technically an HTTP connection upgrade, but simply redirects HTTP to HTTPS if necessary. It tries to figure out if HTTPS is required by the enforce-https config setting and by detecting the protocol of the original request, usually via the x-forwarded-proto header. If running in AWS run Ocelot behind an ELB forwarding HTTP on port 80 and SSL on port 443. HTTP will add the proxy header so Ocelot will redirect to HTTPS. SSL is required for websockets in AWS.
*  **Cookie Parser:** Parses the request cookie header into a req.cookie property.
*  **Route Resolver:** HTTP requests come in with a path and a Host header. Combined, they show what URL was originally requested by the user. Ocelot looks in the backend for a route best matching the host/path combo. If no route is found, Ocelot chomps off the path segments until a configuration is found. That matching configuration is set as the req._route. If no route is found a 404 is returned to the caller.
*  **Exchange:** Ocelot uses a couple reserved paths, one being to complete the auth code exchanage. When the URL ends with /receive-auth-token Ocelot knows it is supposed to grab the code query parameter and complete the login process.
*  **Token Refresh:** Ocelot uses a couple reserved paths, one being to force refresh of the token. When the URL ends with /auth-token-refresh Ocelot knows it is supposed to take the refresh token from the request and exchange it for a new token and refresh token.
*  **Internal Filter:** Ocelot runs a proxy server on two ports. One port is dedicated for internal traffic only. If you set your route configuration to be internal only, Ocelot will filter out traffic that did not come in on the internal port. This is to prevent host spoofing in case you use Ocelot to route to multiple domains and some are private, some are public.
*  **Validate Authentication:** Ocelot will validate your token, or check in the token cache and see if it already knows it is valid. Ocelot currently does not run a cache cluster, so each instance individually manages its own token cache. It is simple and therefore maybe less error prone, but not extremely efficient. The result of the validation is set as the req._auth.
*  **Profile:** If Ocelot can determine the calling user it can add that user's profile information to the request in the form of an HTTP header called 'user-profile'. This middleware adds it by calling the profile endpoint with the user and entitlement application id from the route configuration.
*  **Token Info:** This endpoint gives you metadata about an endpoint's security token. Ocelot gives a lot of information to backends, but frontends may need to grab a token to make an authenticated call to another API, or simply get the profile information for the user. This is another reserved path, when the URL ends with /auth-token-info.
*  **Client Whitelist:** When Ocelot validates tokens it can optionally reject requests if the calling client Id is not in the configured list. This middleware takes the req._auth.client_id and checks it against the req._route whitelist.
*  **Request Headers:** Adds request data to HTTP headers, such as the client-id, user-id and user-profile.
*  **Backend Host:** Takes the configured route's service URLs and hosts (two different versions of the same thing) and randomly picks one. It sets the result as the route._url.
*  **Proxy:** Proxies the request to the new backend host.

## API
Ocelot has a very simply to use API. It usually runs on port 81. The API PUTs only accepts JSON and filters out any fields which are not in the list of accepted fields. API calls also validate Auth headers and store the calling user as the 'user-id' field. _rev is included to support Couch.

* **/api/v1/routes** Supports GET, PUT, DELETE. The path you use is the route identifier which matches the host/path. Example: /api/v1/routes/my.ocelot.local/appa
*
 * **Accepted fields:** ['capture-pattern', 'rewrite-pattern', 'services', 'require-auth', 'client-whitelist',
  'user-header', 'client-header', 'user-id', 'custom-headers', 'ent-app-id', 'user-profile-enabled',
  'elevated-trust', 'internal', 'hosts', '_rev', 'cookie-name', 'client-id', 'client-secret', 'scope', 'cookie-path', 'cookie-domain']

 If the cookie-name is not set many security fields will be blanked out.

 * **UI Security fields:** ['cookie-name', 'client-id', 'client-secret', 'scope', 'cookie-path', 'cookie-domain']

* **/api/v1/hosts** Supports GET, PUT, DELETE. The path you use indicates the service name/ id. Example: /api/v1/hosts/serviceA/serviceinstance0

  * **Accepted fields:** ['url', 'user-id', '_rev']

## Reserved Routes

* **auth-token-info:** Auth token info allows you to query Ocelot for information about the current route, usually from the front-end. Since user-profile headers are only added to each request going to the server, sometimes it is helpful to be able to get the same information in a UI. This route is relative to your current page; if the current page is myexample.com/testapp then you should call myexample.com/testapp/auth-token-info.
* **auth-token-refresh:** Auth token should show you how long the token has to expire in an expires_in property. You may want to refresh your token from a browser on a background timer when you detect your session is about to expire. To do so, call this endpoint. It will return the new token information.
* **receive-auth-token:** Any route ending in this segment Ocelot will assume it is supposed to be taking part in logging the user in via OAuth authentication code flow. Never call this directly.

## Running in AWS

* Run a CouchDB or Consul cluster. Unfortunately, there are no AWS services for these so we use a cloud formation template. Ocelot does have Redis support, but I found the redis package loses connection to AWS Redis periodically, so I stopped using it. I run a two node CouchDB with replication between the two and an ELB between them. Only allow DB access from the Ocelot security group.
* Run Ocelot in an autoscaling group. Ocelot should be listening by default on port 80, 81 & 82. Port 80 is the proxy, 81 is the API and 82 is the "internal" proxy.
* Run an external ELB, modify listeners to allow HTTP on port 80 and forward it to Ocelot on port 80. Also, take in SSL on 443, terminate SSL and forward to port 80. Modify the Ocelot security group to allow access from this Ocelot external ELB. Optionally expose port 81 if you want to configure routes remotely. Obviously, be aware the API will be available on the internet so make sure you use a client whitelist for the API.
* Run an internal ELB if you desire, point it to port 82.
* Configure a Route 53 domain to point to the external ELB. Configure an ocelot.local domain for the internal ELB.
* Now, call the API to register routes using the hostnames you just configured.

## Environment Variables
The main router config is read using the 'config' NPM package. Some of these environment variables come directly from that project. Routes (not router) configuration is either read from a 'backend' property  in the router configuration, or it can come directly from an environment variable/ flat file.

* **NODE_CONFIG:** Set this to provide router configuration in a JSON formatted environment variable. This can be used in place of or in conjunction with NODE_ENV. 
* **NODE_CONFIG_DIR:** Use this environment variable to set the directory where ocelot router configuration files are held.
* **NODE_ENV:** Set this to use router configuration from a file with a given name, found in the directory specified by NODE_CONFIG_DIR.
* **OCELOT_ROUTES_PATH:** The path to the route configuration flat file.
