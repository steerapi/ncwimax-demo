OldCtrl = ($scope)->
  $scope.changeExpTab = (value)->
    # console.log value
    $scope.expTab = value
  $scope.expTab = "Throughput and Loss"
  $scope.types = ["Throughput and Loss", "File Transfer"]

  # $scope.experiments = [
  #   expType: "Throughput and Loss"
  #   bsConf: "HARQ only"
  #   status: "done"
  #   result:
  #     loss: 75
  #     throughput: 1.5
  # ,
  #   expType: "Throughput and Loss"
  #   bsConf: "HARQ/ARQ"
  #   status: "done"
  #   result:
  #     loss: 80
  #     throughput: 1
  # ,
  #   expType: "Throughput and Loss"
  #   bsConf: "NC"
  #   redundancy: 10
  #   status: "done"
  #   result:
  #     loss: 1/3*100
  #     throughput: 4
  # ,
  #   expType: "Throughput and Loss"
  #   bsConf: "NC"
  #   redundancy: 20
  #   status: "done"
  #   result:
  #     loss: 2.2/6*100
  #     throughput: 3.8
  # ,
  #   expType: "File Transfer"
  #   bsConf: "NC"
  #   redundancy: 10
  #   status: "done"
  #   result:
  #     delay: 20
  # ,
  #   expType: "File Transfer"
  #   bsConf: "NC"
  #   redundancy: 20
  #   status: "scheduled"
  #   result:
  #     delay: "-"
  # ,
  #   expType: "Throughput and Loss"
  #   bsConf: "HARQ and ARQ"
  #   status: "running"
  #   result:
  #     loss: "-"
  #     throughput: "-"
  # ,
  #   expType: "File Transfer"
  #   bsConf: "HARQ and ARQ"
  #   status: "running"
  #   result:
  #     delay: "-"
  # ]

  $scope.dData = new google.visualization.DataTable()
  $scope.dData.addColumn('string', 'Configuration')
  $scope.dData.addColumn('number', 'Delay (s)')
  $scope.dchart = new google.visualization.ColumnChart(document.getElementById("dVis"))

  $scope.tData = new google.visualization.DataTable()
  $scope.tData.addColumn('string', 'Configuration')
  $scope.tData.addColumn('number', 'Throughput (Mbps)')
  $scope.tchart = new google.visualization.ColumnChart(document.getElementById("tVis"))

  $scope.lData = new google.visualization.DataTable()
  $scope.lData.addColumn('string', 'Configuration')
  $scope.lData.addColumn('number', 'Loss (%)')
  $scope.lchart = new google.visualization.ColumnChart(document.getElementById("lVis"))
  
  $scope.addRow = (exp)->
    console.log exp
    if exp.selected
      result={}
      if exp.bsConf == "NC"
        exp.bsConf = "NC-"+exp.redundancy
      if exp.expType == "Throughput and Loss"
        result = $scope.addRowThruoghputLoss(exp.bsConf, exp.result.throughput, exp.result.loss)
        $scope.updatePlotThruoghputLoss()
      else
        result = $scope.addRowFileTransfer(exp.bsConf, exp.result.delay)
        $scope.updatePlotFileTransfer()
      angular.extend exp,result
    else
      if exp.expType == "Throughput and Loss"
        $scope.tData.removeRow exp.tIndex
        $scope.lData.removeRow exp.lIndex
        $scope.updatePlotThruoghputLoss()
      else
        $scope.dData.removeRow exp.dIndex
        $scope.updatePlotFileTransfer()

  $scope.addRowThruoghputLoss = (conf,t,l)->
    tIndex = $scope.tData.addRow [conf, t]
    lIndex = $scope.lData.addRow [conf, l]
    return {
      tIndex: tIndex
      lIndex: lIndex
    }

  $scope.addRowFileTransfer = (conf,d)->
    dIndex = $scope.dData.addRow [conf, d]
    return {
      dIndex: dIndex
    }
  $scope.updatePlotThruoghputLoss = ->
    $scope.tchart.draw $scope.tData,
      width: 380
      height: 300
      legend: {position: 'in'}
      vAxis:
        viewWindow:
          max: 6
    $scope.lchart.draw $scope.lData,
      width: 380
      height: 300
      legend: {position: 'in'}
      vAxis:
        viewWindow:
          max: 100
  $scope.updatePlotFileTransfer = ->
    $scope.dchart.draw $scope.dData,
      width: 800
      height: 300
      legend: {position: 'in'}
          
  $scope.updatePlotThruoghputLoss()
  $scope.updatePlotFileTransfer()

MainCtrl = ($scope)->
  
  $scope.tab = "Home"
  $scope.exp = 
    expType: null
    bsConf: null
    redundancy: 10
  $scope.node1Status = "OFF"
  $scope.node2Status = "OFF"
  if localStorage.getItem("exp")
    $scope.experiments = angular.fromJson(localStorage.getItem("exp"))
  else
    $scope.experiments = []
    localStorage.setItem "exp", angular.toJson($scope.experiments)

  socket = io.connect()
  socket.on "consolelog", (data)->
    txt = $("#status")
    txt.val( txt.val() + data)
    txt.scrollTop(txt[0].scrollHeight - txt.height())
  socket.on "status", (data)->
    $scope.node1Status=data[0]
    $scope.node2Status=data[1]
    $scope.$apply()
  socket.on "update", (data)->
    console.log "ERROR",data
    if data.status == "done"
      $scope.tab = "Scheduled Experiments"
    exp = $scope.experiments[data.id]
    $.extend true,exp,data
    localStorage.setItem "exp", angular.toJson($scope.experiments)
    $scope.$apply()
  $scope.cancel = (exp)->
    exp.status = "canceled"
    delete $scope.experiments[exp.id]
    socket.emit "cancel", exp
  $scope.getN1Class = ->
    if $scope.node1Status == "ON"
      "btn-success"
    else
      "btn-warning"
  $scope.getN2Class = ->
    if $scope.node2Status == "ON"
      "btn-success"
    else
      "btn-warning"
  $scope.setup = ->
    $scope.tab = "Status"
    socket.emit "setup"
  $scope.schedule = ->
    $scope.tab = "Status"
    exp = $.extend true,
      id: $scope.experiments.length
      status: "scheduled"
    ,$scope.exp
    if exp.expType == "Throughput and Loss"
      exp.result =
        loss: "-"
        throughput: "-"
    else if exp.expType == "File Transfer"
      exp.result =
        delay: "-"   
    $scope.experiments.push exp
    socket.emit 'schedule', angular.toJson(exp)

  $scope.abstract = """

We design and implement a network-coding-enabled relia-
bility architecture for next generation wireless networks. Our network
coding (NC) architecture uses a 
exible thread-based design, with each
encoder-decoder instance applying systematic intra-session random lin-
ear network coding as a packet erasure code at the IP layer. Using GENI
WiMAX platforms, a series of point-to-point transmission experiments
were conducted to compare the performance of the NC architecture
to that of the Automatic Repeated reQuest (ARQ) and Hybrid ARQ
(HARQ) mechanisms. In our scenarios, the proposed architecture is able
to decrease packet loss from around 11-32% to nearly 0%; compared to
HARQ and joint HARQ/ARQ mechanisms, the NC architecture oers
up to 5.9 times gain in throughput and 5.5 times reduction in end-to-
end le transfer delay. By establishing NC as a potential substitute for
HARQ/ARQ, our experiments offer important insights into cross-layer
designs of next generation wireless networks.

"""