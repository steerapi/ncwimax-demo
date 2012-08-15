nexpect = require("nexpect")
_ = require("underscore")

cps = []
exports.cancel = ->
  for cp in cps
    cp.kill("SIGHUP")

exec = (cmd, cb, stream="stdout")->
  try
    cp = nexpect.spawn("ssh", ["steerapi@console.sb4.orbit-lab.org", cmd],{verbose:true,stream:stream})
    .run cb
    cps.push cp
    cp
  catch e
    cb?()

parseIperfRow = (row)->
  items = row.replace?(/\s/,"").split(",")[...-2]
  items = _.filter items, (item)->
    item if item
  count = 0
  type = [parseInt,parseInt,_.identity,parseInt,parseInt,_.identity,parseInt,parseInt, _.identity]
  label = ["timestamp","id","interval","transfer_bytes","bandwidth_bps","jitter_ms","lost","total", "percent"]
  items = _.reduce items, (memo, item)->
    memo[label[count]] = type[count](item)
    count++
    memo
  , {}
  items

parseUFTP = (data)->
  result = {}
  try
    unless data
      return result
    time_s = data.match /Total elapsed time: (\d+\.\d+) seconds/
    bw_kbytes = data.match /Overall throughput: (\d+\.\d+) KB\/s/
    total_nacks = data.match /NAKs: (\d+)/

    result.bw_kbytes = parseFloat(bw_kbytes[1])
    result.time_s = parseFloat(time_s[1])
    result.total_nacks = parseFloat(total_nacks[1])
    result
  catch err
    result
  # num_blocks: parseFloat(num_blocks?[1])

# console.log parseUFTP """
# 2012/08/15 03:16:39.191412: Transfer status:
# 2012/08/15 03:16:39.191451: Host: 10.41.14.2       Status: Completed   time: 315.388 seconds    NAKs: 67391
# 2012/08/15 03:16:39.191491: Total elapsed time: 315.388 seconds
# 2012/08/15 03:16:39.191514: Overall throughput: 30.96 KB/s
# 2012/08/15 03:16:39.191569: -----------------------------
# 2012/08/15 03:16:39.191605: Finishing group
# 2012/08/15 03:16:39.191660: Sending DONE 1.1
# 2012/08/15 03:16:43.197852: Sending DONE 2.1
# 2012/08/15 03:16:43.276204: Got COMPLETE from client 10.41.14.2
# 2012/08/15 03:16:43.276239: Late completions:
# 2012/08/15 03:16:43.276261: Sending DONE_CONF 3.1
# 2012/08/15 03:16:49.284430: Group complete
# """
parseStatus = (data)->
  try
    node1=data.match /Node n_1_1 - State: POWER([A-Z]+)/
    node2=data.match /Node n_1_2 - State: POWER([A-Z]+)/
    return [node1[1],node2[1]]
  catch err
    return ["OFF","OFF"]

exports.checkNodes = (cb)->
  exec "ncdemo/check.sh", (err, result)->
    cb? parseStatus(result.join("\n"))
# exports.checkNodes (result)->
#   console.log result

exports.setup = (cb)->
  exec "ncdemo/orbit.sh", (err, result)->
    cb? err, result
exports.config = (harq,arq,nc,cb)->
  exec "ncdemo/bs.sh #{harq} #{arq}", (err, result)->
    exec "ncdemo/setup.sh #{nc}", (err, result)->
      cb? err, result

# console.log exports.config 1,0,0
# console.log exports.config 0,0,1
# console.log exports.config 1,1,0

exports.runIperf = (cb)->
  pIperfRecv = exec "ncdemo/run-iperf-receiver.sh", (err, result)->
    unless err
      iperfResult = parseIperfRow(result[-1..][0])
      cb? iperfResult
    else
      cb? err
  exec "ncdemo/run-iperf-sender.sh", (err, result)->
    setTimeout ->
      pIperfRecv.kill('SIGHUP')
    , 2000

# exports.runIperf (result)->
#   console.log "result",result

exports.runUFTP = (cb)->
  exec "ncdemo/run-uftp-receiver.sh", (err, result)->
  exec "ncdemo/run-uftp-sender.sh",(err, result)->
    unless err
      # console.log result
      uftpResult = parseUFTP result.join("\n")
      cb? uftpResult
    else
      cb? err
  ,"stderr"

# exports.runUFTP (result)->
#   console.log "result",result
