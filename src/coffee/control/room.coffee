angular.module 'app.control'

.controller 'app.control.room', [
  '$scope', '$state', '$stateParams', '$kinvey', 'room', 'messages', 'me',
  ($scope, $state, $stateParams, $kinvey, room, messages, me) ->

    $scope.room = room
    $scope.messages = messages

    $scope.send = (text) ->
      message = new $kinvey.Message
        text: text
        from: me
        room: room
      message.$save().then ->
        $scope.text = ''
        message.from = me
        $scope.messages.push message
]