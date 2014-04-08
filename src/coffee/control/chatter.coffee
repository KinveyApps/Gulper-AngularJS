angular.module 'app.control'

.controller 'app.control.chatter', [
  '$scope', '$state', '$stateParams', '$kinvey', 'PubNub', 'rooms', 'messages', 'me',
  ($scope, $state, $stateParams, $kinvey, PubNub, rooms, messages, me) ->

    $scope.rooms = rooms
    $scope.messages = messages

    for room in rooms
      do (room) ->
        PubNub.ngSubscribe
          channel: room._id
        $scope.$on (PubNub.ngMsgEv room._id), (event, payload) ->
          message = new $kinvey.Message payload
          $scope.messages.push message
]