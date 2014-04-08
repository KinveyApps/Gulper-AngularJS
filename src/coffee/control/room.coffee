angular.module 'app.control'

.controller 'app.control.room', [
  '$scope', '$state', '$stateParams', '$kinvey', 'PubNub', 'room', 'messages', 'me',
  ($scope, $state, $stateParams, $kinvey, PubNub, room, messages, me) ->

    $scope.room = room
    $scope.messages = messages

    $scope.$parent.notifications[room._id] = 0

    PubNub.ngSubscribe
      channel: room._id

    $scope.$on (PubNub.ngMsgEv room._id), (event, payload) ->
      $scope.$apply ->
        message = new $kinvey.Message (JSON.parse payload.message)
        $scope.messages.push message

    $scope.send = (text) ->
      message = new $kinvey.Message
        text: text
        from: me
        room: room
        _acl:
          r: room._acl.r
          w: room._acl.w
      message.$save().then ->
        $scope.text = ''

    $scope.leaveRoom = ->
      $kinvey.rpc 'leaveRoom',
        room: room
        user: me
]