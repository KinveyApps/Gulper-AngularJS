angular.module 'app.control'

.controller 'app.control.index', ['$scope', '$state', '$facebook', '$kinvey', 'me', ($scope, $state, $facebook, $kinvey, me) ->

  $scope.me = me

  $scope.logout = ->
    $facebook.logout().then ->
      $kinvey.User.logout().$promise.then ->
        $state.go 'login'

]