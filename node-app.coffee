static_ = require("node-static")
http = require("http")
ssh = require("./ssh")
events = require("events")

file = new (static_.Server)("./web")
server = http.createServer((request, response) ->
  request.addListener "end", ->
    file.serve request, response
)
server.listen 80
socketio = require('socket.io')
io = socketio.listen(server)
socket = null

class WorkQueue extends events.EventEmitter
  constructor:->
    @processing = false
    @queue = []
  process:(exp,cb)->
    schedule exp,(result)=>
      if result
        cb result
      @processing = false
      @next()
  next: ->
    if (not @processing) and (@queue.length != 0)
      args = @queue.shift()
      @processing = true
      @process args...
  push: (exp,cb)->
    @queue.push [exp,cb]
    @next(exp,cb)
  cancel: (exp)->
    for q,idx in @queue
      if q[0].id == exp.id
        q.splice idx,1
        return
    ssh.cancel()
    @processing = false
    @next()

queue = new WorkQueue

io.sockets.on "connection", (_socket) ->
  socket = _socket
  setTimeout chk=->
    ssh.checkNodes (status)->
      socket.emit "status", status
      setTimeout chk, 5000
  , 5000
  socket.on "cancel", (data)->
    queue.cancel data
  socket.on "setup", (data)->
    ssh.setup()
  socket.on "schedule", (data)->
    exp = JSON.parse data
    queue.push exp, (result)->
      exp.status = "done"
      switch exp.expType
        when "Throughput and Loss"
          exp.result =
            loss: (result.lost/result.total*100)
            throughput: (result.bandwidth_bps/1000000)
        when "File Transfer"
          exp.result = 
            delay: (result.time_s)
      console.log exp.result
      socket.emit "update", exp
    
schedule = (exp,cb)->
  exp.status = "running"
  socket.emit "update", exp
  run = ->
    switch exp.expType
      when "Throughput and Loss"
        ssh.runIperf cb
        # cb 
        #   bandwidth_bps: 1058400
        #   lost: 10
        #   total: 45
      when "File Transfer"
        ssh.runUFTP cb
        # cb 
        #   time_s: 20
  # run()
  switch exp.bsConf
    when "HARQ and ARQ"
      ssh.config 1,1,0,run
    when "HARQ only"
      ssh.config 1,0,0,run
    when "NC"
      ssh.config 0,0,0,run
