google.load('visualization', '1', {packages: ['corechart']});
google.setOnLoadCallback ->
  $(document).ready ->
    app = angular.module "slider", []
    app.directive "slider", ($parse)->
      link: (scope,element,attrs)->
        getter = $parse(attrs.slider)
        setter = getter.assign
        element.slider
          value: getter(scope)
          slide: (e,ui)->
            setter(scope, ui.value)
            scope.$apply()

    app.directive "ngActive", ->
      (scope,element,attrs)->
        scope.$watch attrs.ngActive, ->
          if scope.$eval(attrs.ngActive)
            element.addClass("active")
          else
            element.removeClass("active")
    angular.bootstrap document, ["slider"]