// Generated by CoffeeScript 1.3.3
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
    console.log(exp);
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
  var socket;
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
  socket.on("consolelog", function(data) {
    var txt;
    txt = $("#status");
    txt.val(txt.val() + data);
    return txt.scrollTop(txt[0].scrollHeight - txt.height());
  });
  socket.on("status", function(data) {
    $scope.node1Status = data[0];
    $scope.node2Status = data[1];
    return $scope.$apply();
  });
  socket.on("update", function(data) {
    var exp;
    console.log("ERROR", data);
    if (data.status === "done") {
      $scope.tab = "Scheduled Experiments";
    }
    exp = $scope.experiments[data.id];
    $.extend(true, exp, data);
    localStorage.setItem("exp", angular.toJson($scope.experiments));
    return $scope.$apply();
  });
  $scope.cancel = function(exp) {
    exp.status = "canceled";
    delete $scope.experiments[exp.id];
    return socket.emit("cancel", exp);
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
  $scope.setup = function() {
    $scope.tab = "Status";
    return socket.emit("setup");
  };
  $scope.schedule = function() {
    var exp;
    $scope.tab = "Status";
    exp = $.extend(true, {
      id: $scope.experiments.length,
      status: "scheduled"
    }, $scope.exp);
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
    return socket.emit('schedule', angular.toJson(exp));
  };
  return $scope.abstract = "\nWe design and implement a network-coding-enabled relia-\nbility architecture for next generation wireless networks. Our network\ncoding (NC) architecture uses a \nexible thread-based design, with each\nencoder-decoder instance applying systematic intra-session random lin-\near network coding as a packet erasure code at the IP layer. Using GENI\nWiMAX platforms, a series of point-to-point transmission experiments\nwere conducted to compare the performance of the NC architecture\nto that of the Automatic Repeated reQuest (ARQ) and Hybrid ARQ\n(HARQ) mechanisms. In our scenarios, the proposed architecture is able\nto decrease packet loss from around 11-32% to nearly 0%; compared to\nHARQ and joint HARQ/ARQ mechanisms, the NC architecture oers\nup to 5.9 times gain in throughput and 5.5 times reduction in end-to-\nend le transfer delay. By establishing NC as a potential substitute for\nHARQ/ARQ, our experiments offer important insights into cross-layer\ndesigns of next generation wireless networks.\n";
};
