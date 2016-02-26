Prometheus = require 'prometheus-client'
os = require 'os'
prom = new Prometheus()

func = prom.metricsFunc()

heap_total_gauge = prom.newGauge
    namespace: "nodejs"
    name: "heap_total_mb"
    help: "The total heap memory of the process."

heap_used_gauge = prom.newGauge
    namespace: "nodejs"
    name: "heap_used_mb"
    help: "The used heap memory of the process."

cpu_load_gauge = prom.newGauge
    namespace: "nodejs"
    name: "cpu_load_1m"
    help: "The 1 minute cpu load of the system."

uptime_gauge = prom.newGauge
    namespace: "nodejs"
    name: "uptime_seconds"
    help: "The number of seconds the process has been running."

currentConnections = 0
currentConnectionsGauge = prom.newGauge
    namespace: "nodejs"
    name: "current_connections"
    help: "The number of current connections"

requestCount = 0
requestCountGauge = prom.newGauge
    namespace: "nodejs"
    name: "request_count"
    help: "The raw number of proxy requests"

clientCalls = {}
clientCallGauge = prom.newGauge
    namespace: ""
    name: "client_calls"
    help: "The raw number of proxy requests"

setInterval =>
    heap_total_gauge.set period: "15sec", (process.memoryUsage().heapTotal / 1000000).toFixed(2)
    heap_used_gauge.set period: "15sec", (process.memoryUsage().heapUsed / 1000000).toFixed(2)
    cpu_load_gauge.set period: "15sec", (os.loadavg()[0]).toFixed(2)
    uptime_gauge.set period: "15sec", process.uptime().toFixed(2)
    currentConnectionsGauge.set period: "15sec", currentConnections
    requestCountGauge.set period: "15sec", requestCount
    requestCount=0
    Object.keys(clientCalls).forEach (client) ->
        requestCountGauge.set period: "15sec", requestCount

, 15000

module.exports =
    connectionOpened: (req)->
        currentConnections++
        requestCount++
    connectionClosed: (req) ->
        currentConnections--

    authLog: (req, route) ->


    metricsFunc: -> func





