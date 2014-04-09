angular.module 'app.control'

.controller 'app.control.settings', [
  '$scope', '$state', '$kinvey', 'me',
  ($scope, $state, $kinvey, me) ->

    $scope.me = me
    $scope.logout = ->
        $kinvey.User.logout().$promise.then ->
          $state.go 'login'

    $scope.userName = (user) ->
      if user._socialIdentity.facebook
        user._socialIdentity.facebook.name
      else if user._socialIdentity.google
        user._socialIdentity.google.given_name + ' ' + user._socialIdentity.google.family_name
      else
        user.username

    $scope.save = ->
      $scope.me.$save().then ->
        $state.go 'index.chatter'
]