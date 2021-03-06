// Generated by CoffeeScript 1.3.3
var consolestream, cps, events, exec, nexpect, parseIperfRow, parseStatus, parseUFTP, stream, _;

nexpect = require("./nexpect");

_ = require("underscore");

stream = require('stream');

events = require("events");

consolestream = new stream.Stream();

consolestream.writable = true;

consolestream.write = function(data) {
  return true;
};

exports.consolestream = consolestream;

cps = [];

exports.cancel = function() {
  var cp, _i, _len;
  try {
    for (_i = 0, _len = cps.length; _i < _len; _i++) {
      cp = cps[_i];
      cp.kill("SIGINT");
      cp.kill("SIGHUP");
      cp.kill("SIGTERM");
    }
  } catch (error) {
    console.log(error);
  }
  return cps = [];
};

exec = function(cmd, cb, _consolestream, stream) {
  var cp;
  if (_consolestream == null) {
    _consolestream = consolestream;
  }
  if (stream == null) {
    stream = "stdout";
  }
  try {
    cp = nexpect.spawn("ssh", ["-o", "StrictHostKeyChecking=no", "fouli@console.sb4.orbit-lab.org", cmd], {
      verbose: true,
      stream: stream,
      consolestream: _consolestream
    }).run(cb);
    cps.push(cp);
    return cp;
  } catch (e) {
    return typeof cb === "function" ? cb() : void 0;
  }
};

parseIperfRow = function(row) {
  var count, items, label, type;
  if (!row) {
    return null;
  }
  items = typeof row.replace === "function" ? row.replace(/\s/, "").split(",").slice(0, -2) : void 0;
  items = _.filter(items, function(item) {
    if (item) {
      return item;
    }
  });
  count = 0;
  type = [parseInt, parseInt, _.identity, parseInt, parseInt, _.identity, parseInt, parseInt, _.identity];
  label = ["timestamp", "id", "interval", "transfer_bytes", "bandwidth_bps", "jitter_ms", "lost", "total", "percent"];
  items = _.reduce(items, function(memo, item) {
    memo[label[count]] = type[count](item);
    count++;
    return memo;
  }, {});
  return items;
};

parseUFTP = function(data) {
  var bw_kbytes, result, time_s, total_nacks;
  result = {};
  try {
    if (!data) {
      return result;
    }
    time_s = data.match(/Total elapsed time: (\d+\.\d+) seconds/);
    bw_kbytes = data.match(/Overall throughput: (\d+\.\d+) KB\/s/);
    total_nacks = data.match(/NAKs: (\d+)/);
    result.bw_kbytes = parseFloat(bw_kbytes[1]);
    result.time_s = parseFloat(time_s[1]);
    result.total_nacks = parseFloat(total_nacks[1]);
    return result;
  } catch (err) {
    return result;
  }
};

parseStatus = function(data) {
  var node1, node2, nodes;
  try {
    nodes = data.split('\n');
    node1 = nodes[0] === '1' ? "ON" : "OFF";
    node2 = nodes[1] === '1' ? "ON" : "OFF";
    return [node1, node2];
  } catch (err) {
    return ["OFF", "OFF"];
  }
};

exports.checkOrbit = function(cb) {
  var statusStream;
  statusStream = new stream.Stream();
  statusStream.writable = true;
  statusStream.write = function(data) {
    return true;
  };
  return exec("ls", function(err, result) {
    return typeof cb === "function" ? cb(result.length > 0) : void 0;
  }, statusStream);
};

exports.checkNodes = function(cb) {
  var statusStream;
  statusStream = new stream.Stream();
  statusStream.writable = true;
  statusStream.write = function(data) {
    return true;
  };
  return exec("ncdemo/check-nodes.sh", function(err, result) {
    return typeof cb === "function" ? cb(parseStatus(result.join("\n"))) : void 0;
  }, statusStream);
};

exports.setup = function(cb) {
  return exec("ncdemo/orbit.sh", function(err, result) {
    return typeof cb === "function" ? cb(err, result) : void 0;
  });
};

exports.restartBS = function(cb) {};

exports.config = function(harq, arq, nc, redundancy, cb) {
  return exec("ncdemo/bs.sh " + harq + " " + arq + " && ncdemo/setup.sh " + nc + " " + redundancy, function(err, result) {
    return typeof cb === "function" ? cb(err, result) : void 0;
  });
};

exports.runIperf = function(cb) {
  var pIperfRecv;
  pIperfRecv = exec("ncdemo/run-iperf-receiver.sh", function(err, result) {
    var iperfResult;
    if (!err) {
      iperfResult = parseIperfRow(result.slice(-1)[0]);
      return typeof cb === "function" ? cb(iperfResult) : void 0;
    } else {
      return typeof cb === "function" ? cb(err) : void 0;
    }
  });
  return exec("ncdemo/run-iperf-sender.sh", function(err, result) {
    return setTimeout(function() {
      return pIperfRecv.kill('SIGHUP');
    }, 2000);
  });
};

exports.runUFTP = function(cb) {
  exec("ncdemo/run-uftp-receiver.sh", function(err, result) {});
  return exec("ncdemo/run-uftp-sender.sh", function(err, result) {
    var uftpResult;
    if (!err) {
      console.log(result);
      uftpResult = parseUFTP(result.join("\n"));
      console.log("parsed", uftpResult);
      return typeof cb === "function" ? cb(uftpResult) : void 0;
    } else {
      return typeof cb === "function" ? cb(err) : void 0;
    }
  });
};
