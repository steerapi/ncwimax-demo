static_ = require("node-static")
http = require('http')
events = require("events")
ssh = require("./ssh")
file = new (static_.Server)("./web")
server = http.createServer((request, response) ->
  file.serve request, response
)
server.listen 8081
socketio = require('socket.io')
io = socketio.listen(server)
socket = null

#states=["busy","idle"]
state="idle"
his1=""
his2=""

ssh.consolestream.write = (data)->
  his2+=data.toString()
  # io.sockets.emit "consolelog", data.toString()
  true

setTimeout upd=->
  io.sockets.emit "state", 
    state:state
    his1:his1
    his2:his2
  setTimeout upd,1000
, 1000

io.sockets.on "connection", (_socket) ->
  socket = _socket
  socket.emit "state", state
  socket.on "checkNodes", (data)->
    ssh.checkNodes (status)->
      socket.emit "checkNodes", status
  socket.on "checkOrbit", (data)->
    ssh.checkOrbit (canAccess)->
      socket.emit "checkOrbit", canAccess
  socket.on "cancel", (data)->
    ssh.cancel()
    socket.emit "cancel"
  socket.on "setup", (data)->
    if state=="busy"
      ssh.cancel()
      ssh.cancel()
      ssh.cancel()      
    his1="Setting up nodes 1 and 2. This operation takes up to 15 minuites.\n"
    his2=""
    state="busy"
    ssh.setup ->
      socket.emit "setup"
      state="idle"
  socket.on "run", (data)->
    if state=="busy"
      exp.status = "error"
      socket.emit "update", exp      
      return
    state="busy"
    exp = JSON.parse data
    schedule exp,(result)=>
      state="idle"
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
  txt = "\nRunning #{exp.expType} experiment with #{exp.bsConf}"
  if exp.bsConf == "NC"
    txt+="-#{exp.redundancy}"
  his1=txt
  his2=""
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
    when "ARQ only"
      ssh.config 0,1,0,run
    when "HARQ only"
      ssh.config 1,0,0,run
    when "NC"
      ssh.config 0,0,1,run
    when "Raw"
      ssh.config 0,0,0,run
