angular.module 'app.control'

.controller 'app.control.room', [
  '$scope', '$state', '$kinvey', 'room',
  ($scope, $state, $kinvey, room) ->

    $scope.room = room
]