static_ = require("node-static")
httpdigest = require('http-digest')
events = require("events")
ssh = require("./ssh")
file = new (static_.Server)("./web")
server = httpdigest.createServer("fouli", "fouli", (request, response) ->
  request.addListener "end", ->
    file.serve request, response
)
server.listen 8081
socketio = require('socket.io')
io = socketio.listen(server)
socket = null

previousClient = null
io.sockets.on "connection", (_socket) ->
  socket = _socket
  socket.on "disconnect", ->
    ssh.cancel()
  if previousClient
    previousClient.disconnect()
  previousClient = socket
  chk=->
    ssh.checkNodes (status)->
      socket.emit "status", status
      setTimeout chk, 5000
  chk()
  ssh.consolestream.write = (data)->
    socket.emit "consolelog", data.toString()
    true
  socket.on "cancel", (data)->
    ssh.cancel()
    socket.emit "ready"
  socket.on "setup", (data)->
    ssh.setup ->
      socket.emit "setupExecuted"
  socket.on "run", (data)->
    exp = JSON.parse data
    schedule exp,(result)=>
      if not result
        exp.status = "error"
        socket.emit "update", exp
        return
      exp.status = "done"
      switch exp.expType
        when "Throughput and Loss"
          exp.result =
            loss: (result.lost/result.total*100)
            throughput: (result.bandwidth_bps/1000000)
        when "File Transfer"
          exp.result = 
            delay: (result.time_s)
      socket.emit "update", exp
      socket.emit "ready"

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
