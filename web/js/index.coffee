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

MainCtrl = ($scope,$timeout)->
  $scope.isNodeReady = ->
    return $scope.node1Status == "ON" and $scope.node2Status == "ON"
  $scope.activeStep = 1

  appendStatus = (data)->
    txt = $("#status")
    txt.val( txt.val() + data)
    txt.scrollTop(txt[0].scrollHeight - txt.height())
  appendStatusLog = (data)->
    txt = $("#statusLog")
    txt.val( txt.val() + data)
    txt.scrollTop(txt[0].scrollHeight - txt.height())
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

  $timeout chk=->
    if $scope.activeStep==1
      socket.emit "checkOrbit"
    else if $scope.activeStep==2
      socket.emit "checkNodes"
    $timeout chk,1000
  , 1000

  socket.on "consolelog", (data)->
    appendStatusLog data
  socket.on "disconnect", (data)->
    # alert "You are disconnected. Please refresh the page before continuing."
  socket.on "state", (data)->
    $scope.state = data.state
    txt = $("#status")
    txt.val( data.his1 )
    txt.scrollTop(txt[0].scrollHeight - txt.height())
    txt = $("#statusLog")
    txt.val( data.his2 )
    txt.scrollTop(txt[0].scrollHeight - txt.height())
    $scope.$apply()
  socket.on "checkOrbit", (access)->
    if(access)
      $scope.activeStep=2
  socket.on "checkNodes", (data)->
    $scope.node1Status=data[0]
    $scope.node2Status=data[1]
    if $scope.isNodeReady()
      $scope.setupDisabled = true
      $scope.activeStep=3
    else
      $scope.setupDisabled = false
    $scope.$apply()
  socket.on "update", (data)->
    if data.status == "done"
      $scope.tab = "Scheduled Experiments"
    exp = $scope.experiments[data.id]
    $.extend true,exp,data
    localStorage.setItem "exp", angular.toJson($scope.experiments)
    $scope.$apply()
  $scope.setupDisabled = true
  currentExp = {}
  $scope.resetClicked = false
  $scope.cancelCurrent = ->
    delete $scope.experiments[currentExp.id]
    socket.emit "cancel", currentExp
    localStorage.setItem "exp", angular.toJson($scope.experiments)
  $scope.reset = (exp)->
    $scope.resetClicked = true
    $timeout ->
      $scope.resetClicked = false
    , 2000
    socket.emit "cancel"
  $scope.cancel = (exp)->
    delete $scope.experiments[exp.id]
    socket.emit "cancel", exp
    localStorage.setItem "exp", angular.toJson($scope.experiments)
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
    
  socket.on "setupExecuted", (data)->
    $scope.setupDisabled = false
  $scope.setup = ->
    # appendStatus "Setting up nodes 1 and 2. This operation takes up to 15 minuites.\n"
    $scope.setupDisabled = true
    socket.emit "setup"

  scheduleDisabled = false
  $scope.schedule = ->
    exp = $.extend true,
      id: $scope.experiments.length
      status: "scheduled"
    ,$scope.exp
    currentExp = exp
    # txt = "\nRunning #{exp.expType} experiment with #{exp.bsConf}"
    # if exp.bsConf == "NC"
    #   txt+="-#{exp.redundancy}"
    # appendStatus txt
    if exp.expType == "Throughput and Loss"
      exp.result =
        loss: "-"
        throughput: "-"
    else if exp.expType == "File Transfer"
      exp.result =
        delay: "-"   
    $scope.experiments.push exp
    socket.emit 'run', angular.toJson(exp)

  $scope.abstract = """"""