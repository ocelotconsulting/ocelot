Prometheus = require 'prometheus-client'
os = require 'os'
prom = new Prometheus()

func = prom.metricsFunc()

heap_total_gauge = prom.newGauge
    namespace: ""
    name: "heap_total_mb"
    help: "The total heap memory of the process."

heap_used_gauge = prom.newGauge
    namespace: ""
    name: "heap_used_mb"
    help: "The used heap memory of the process."

cpu_load_gauge = prom.newGauge
    namespace: ""
    name: "cpu_load_1m"
    help: "The 1 minute cpu load of the system."

uptime_gauge = prom.newGauge
    namespace: ""
    name: "uptime_seconds"
    help: "The number of seconds the process has been running."

currentRequests = 0
currentRequestsGauge = prom.newGauge
    namespace: ""
    name: "current_requests"
    help: "The number of current requests"

requestCount = 0
requestCountGauge = prom.newGauge
    namespace: ""
    name: "request_count"
    help: "The number of proxy requests"

totalElapsedTime = 0
responseTimeAvgGauge = prom.newGauge
    namespace: ""
    name: "avg_response_time"
    help: "The average response time average in ms"

setInterval =>
    heap_total_gauge.set period: "15sec", (process.memoryUsage().heapTotal / 1000000).toFixed(2)
    heap_used_gauge.set period: "15sec", (process.memoryUsage().heapUsed / 1000000).toFixed(2)
    cpu_load_gauge.set period: "15sec", (os.loadavg()[0]).toFixed(2)
    uptime_gauge.set period: "15sec", process.uptime().toFixed(2)
    currentRequestsGauge.set period: "15sec", currentRequests
    requestCountGauge.set period: "15sec", requestCount
    responseTimeAvg = if requestCount == 0 then 0 else (totalElapsedTime / requestCount).toFixed(2)
    responseTimeAvgGauge.set period: "15sec", responseTimeAvg
    requestCount=0
    totalElapsedTime=0

, 15000

module.exports =
    requestProcessing: (req)->
      #_ws signifies a websocket, omit timing and request count
      if not req._ws
        req._time = new Date().getTime()
        requestCount++
      currentRequests++
    requestFinished: (req) ->
      currentRequests--
      if req._time
        totalElapsedTime+=(new Date().getTime() - req._time)

    metricsFunc: -> func
