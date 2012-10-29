// Generated by CoffeeScript 1.4.0
var MainCtrl, OldCtrl;

OldCtrl = function($scope) {
  $scope.changeExpTab = function(value) {
    return $scope.expTab = value;
  };
  $scope.expTab = "Throughput and Loss";
  $scope.types = ["Throughput and Loss", "File Transfer"];
  $scope.dData = new google.visualization.DataTable();
  $scope.dData.addColumn('string', 'Configuration');
  $scope.dData.addColumn('number', 'Delay (s)');
  $scope.dchart = new google.visualization.ColumnChart(document.getElementById("dVis"));
  $scope.tData = new google.visualization.DataTable();
  $scope.tData.addColumn('string', 'Configuration');
  $scope.tData.addColumn('number', 'Throughput (Mbps)');
  $scope.tchart = new google.visualization.ColumnChart(document.getElementById("tVis"));
  $scope.lData = new google.visualization.DataTable();
  $scope.lData.addColumn('string', 'Configuration');
  $scope.lData.addColumn('number', 'Loss (%)');
  $scope.lchart = new google.visualization.ColumnChart(document.getElementById("lVis"));
  $scope.addRow = function(exp) {
    var result;
    if (exp.selected) {
      result = {};
      if (exp.bsConf === "NC") {
        exp.bsConf = "NC-" + exp.redundancy;
      }
      if (exp.expType === "Throughput and Loss") {
        result = $scope.addRowThruoghputLoss(exp.bsConf, exp.result.throughput, exp.result.loss);
        $scope.updatePlotThruoghputLoss();
      } else {
        result = $scope.addRowFileTransfer(exp.bsConf, exp.result.delay);
        $scope.updatePlotFileTransfer();
      }
      return angular.extend(exp, result);
    } else {
      if (exp.expType === "Throughput and Loss") {
        $scope.tData.removeRow(exp.tIndex);
        $scope.lData.removeRow(exp.lIndex);
        return $scope.updatePlotThruoghputLoss();
      } else {
        $scope.dData.removeRow(exp.dIndex);
        return $scope.updatePlotFileTransfer();
      }
    }
  };
  $scope.addRowThruoghputLoss = function(conf, t, l) {
    var lIndex, tIndex;
    tIndex = $scope.tData.addRow([conf, t]);
    lIndex = $scope.lData.addRow([conf, l]);
    return {
      tIndex: tIndex,
      lIndex: lIndex
    };
  };
  $scope.addRowFileTransfer = function(conf, d) {
    var dIndex;
    dIndex = $scope.dData.addRow([conf, d]);
    return {
      dIndex: dIndex
    };
  };
  $scope.updatePlotThruoghputLoss = function() {
    $scope.tchart.draw($scope.tData, {
      width: 380,
      height: 300,
      legend: {
        position: 'in'
      },
      vAxis: {
        viewWindow: {
          max: 6
        }
      }
    });
    return $scope.lchart.draw($scope.lData, {
      width: 380,
      height: 300,
      legend: {
        position: 'in'
      },
      vAxis: {
        viewWindow: {
          max: 100
        }
      }
    });
  };
  $scope.updatePlotFileTransfer = function() {
    return $scope.dchart.draw($scope.dData, {
      width: 800,
      height: 300,
      legend: {
        position: 'in'
      }
    });
  };
  $scope.updatePlotThruoghputLoss();
  return $scope.updatePlotFileTransfer();
};

MainCtrl = function($scope) {
  var appendStatus, appendStatusLog, currentExp, scheduleDisabled, scl, scrolling, socket, txt1, txt2;
  $scope.isNodeReady = function() {
    return $scope.node1Status === "ON" && $scope.node2Status === "ON";
  };
  $scope.activeStep = 1;
  txt1 = $("#status");
  txt2 = $("#statusLog");
  appendStatus = function(data) {
    txt1.val(txt1.val() + data);
    if (!scrolling) {
      return txt1.scrollTop(txt1[0].scrollHeight - txt1.height());
    }
  };
  appendStatusLog = function(data) {
    txt2.val(txt2.val() + data);
    if (!scrolling) {
      return txt2.scrollTop(txt2[0].scrollHeight - txt2.height());
    }
  };
  $scope.tab = "Home";
  $scope.exp = {
    expType: null,
    bsConf: null,
    redundancy: 10
  };
  $scope.node1Status = "OFF";
  $scope.node2Status = "OFF";
  if (localStorage.getItem("exp")) {
    $scope.experiments = angular.fromJson(localStorage.getItem("exp"));
  } else {
    $scope.experiments = [];
    localStorage.setItem("exp", angular.toJson($scope.experiments));
  }
  socket = io.connect();
  setInterval(function() {
    if ($scope.activeStep === 1) {
      return socket.emit("checkOrbit");
    } else if ($scope.activeStep === 2) {
      return socket.emit("checkNodes");
    }
  }, 1000);
  socket.on("consolelog", function(data) {
    return appendStatusLog(data);
  });
  socket.on("disconnect", function(data) {});
  scrolling = false;
  scl = function() {
    if (!scrolling) {
      scrolling = true;
      return setTimeout(function() {
        return scrolling = false;
      }, 5000);
    }
  };
  txt1.scroll(scl);
  txt2.scroll(scl);
  socket.on("state", function(data) {
    $scope.state = data.state;
    txt1.val(data.his1);
    txt2.val(data.his2);
    if (!scrolling) {
      txt1.scrollTop(txt1[0].scrollHeight - txt1.height());
      txt2.scrollTop(txt2[0].scrollHeight - txt2.height());
    }
    return $scope.$apply();
  });
  socket.on("checkOrbit", function(access) {
    if (access) {
      $scope.activeStep = 2;
      return $scope.$apply();
    }
  });
  socket.on("checkNodes", function(data) {
    $scope.node1Status = data[0];
    $scope.node2Status = data[1];
    if ($scope.isNodeReady()) {
      $scope.setupDisabled = true;
      $scope.activeStep = 3;
    } else {
      $scope.setupDisabled = false;
    }
    return $scope.$apply();
  });
  socket.on("update", function(data) {
    var exp;
    if (data.status === "done") {
      $scope.tab = "Scheduled Experiments";
    }
    exp = $scope.experiments[data.id];
    $.extend(true, exp, data);
    localStorage.setItem("exp", angular.toJson($scope.experiments));
    return $scope.$apply();
  });
  $scope.setupDisabled = true;
  currentExp = {};
  $scope.resetClicked = false;
  $scope.cancelCurrent = function() {
    delete $scope.experiments[currentExp.id];
    socket.emit("cancel", currentExp);
    return localStorage.setItem("exp", angular.toJson($scope.experiments));
  };
  $scope.reset = function(exp) {
    $scope.resetClicked = true;
    $timeout(function() {
      return $scope.resetClicked = false;
    }, 2000);
    return socket.emit("cancel");
  };
  $scope.cancel = function(exp) {
    delete $scope.experiments[exp.id];
    socket.emit("cancel", exp);
    return localStorage.setItem("exp", angular.toJson($scope.experiments));
  };
  $scope.getN1Class = function() {
    if ($scope.node1Status === "ON") {
      return "btn-success";
    } else {
      return "btn-warning";
    }
  };
  $scope.getN2Class = function() {
    if ($scope.node2Status === "ON") {
      return "btn-success";
    } else {
      return "btn-warning";
    }
  };
  socket.on("setupExecuted", function(data) {
    return $scope.setupDisabled = false;
  });
  $scope.setup = function() {
    $scope.setupDisabled = true;
    return socket.emit("setup");
  };
  $scope.restartBS = function() {
    return socket.emit("restartBS");
  };
  scheduleDisabled = false;
  $scope.schedule = function() {
    var exp;
    exp = $.extend(true, {
      id: $scope.experiments.length,
      status: "scheduled"
    }, $scope.exp);
    currentExp = exp;
    if (exp.expType === "Throughput and Loss") {
      exp.result = {
        loss: "-",
        throughput: "-"
      };
    } else if (exp.expType === "File Transfer") {
      exp.result = {
        delay: "-"
      };
    }
    $scope.experiments.push(exp);
    return socket.emit('run', angular.toJson(exp));
  };
  return $scope.abstract = "";
};
