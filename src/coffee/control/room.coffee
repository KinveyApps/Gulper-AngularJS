angular.module 'app.control'

.controller 'app.control.room', [
  '$scope', '$state', '$stateParams', '$kinvey', 'PubNub', 'room', 'messages', 'me', '$subscriber',
  ($scope, $state, $stateParams, $kinvey, PubNub, room, messages, me, $subscriber) ->

    $scope.room = room
    $scope.messages = messages

    $scope.$parent.notifications[room._id] = 0
    $subscriber.subscribe room._id

    $scope.$on (PubNub.ngMsgEv room._id), (event, payload) ->
      $scope.$apply ->
        console.log payload
        payload.message = JSON.parse payload.message
        if !payload.message.type
          message = new $kinvey.Message payload.message
          $scope.messages.push message

    $scope.send = (text) ->
      message = new $kinvey.Message
        text: text
        from: me
        room: room
        _acl:
          r: room._acl.r
          w: room._acl.w
      $scope.text = ''
      message.$save()

    $scope.leaveRoom = ->
      $kinvey.rpc 'leaveRoom',
        room: room
        user: me
]