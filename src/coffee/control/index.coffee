angular.module 'app.control'

.controller 'app.control.index', [
  '$scope', '$state', '$facebook', '$kinvey', 'me', 'users',
  ($scope, $state, $facebook, $kinvey, me, users) ->

    $scope.me = me
    $scope.users = users

    $scope.logout = ->
      $facebook.logout().then ->
        $kinvey.User.logout().$promise.then ->
          $state.go 'login'

]