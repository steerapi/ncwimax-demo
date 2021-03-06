// Generated by CoffeeScript 1.4.0

google.load('visualization', '1', {
  packages: ['corechart']
});

google.setOnLoadCallback(function() {
  return $(document).ready(function() {
    var app;
    app = angular.module("slider", []);
    app.directive("slider", function($parse) {
      return {
        link: function(scope, element, attrs) {
          var getter, setter;
          getter = $parse(attrs.slider);
          setter = getter.assign;
          return element.slider({
            value: getter(scope),
            slide: function(e, ui) {
              setter(scope, ui.value);
              return scope.$apply();
            }
          });
        }
      };
    });
    app.directive("ngActive", function() {
      return function(scope, element, attrs) {
        return scope.$watch(attrs.ngActive, function() {
          if (scope.$eval(attrs.ngActive)) {
            return element.addClass("active");
          } else {
            return element.removeClass("active");
          }
        });
      };
    });
    return angular.bootstrap(document, ["slider"]);
  });
});
