angular.module 'app.control'

.controller 'app.control.index', ['$scope', '$state', '$facebook', '$kinvey', ($scope, $state, $facebook, $kinvey) ->

  $scope.logout = ->
    $facebook.logout().then ->
      $kinvey.User.logout().$promise.then ->
        $state.go 'login'

]