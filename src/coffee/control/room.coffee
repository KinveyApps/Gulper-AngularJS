angular.module 'app.control'

.controller 'app.control.room', [
  '$scope', '$state', '$stateParams', '$kinvey', 'PubNub', 'room', 'messages', 'me', '$subscriber', '$modal',
  ($scope, $state, $stateParams, $kinvey, PubNub, room, messages, me, $subscriber, $modal) ->

    $scope.room = room
    $scope.messages = messages

    $scope.$parent.notifications[room._id] = 0
    $subscriber.subscribe room._id

    $scope.$on (PubNub.ngMsgEv room._id), (event, payload) ->
      $scope.$apply ->
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
      $scope.send '...has left the room'
        .then ->
          $kinvey.rpc 'leaveRoom',
            room: room
            user: me

    $scope.delete = ->
      room.$delete().then ->
        $state.go 'index.chatter'

    $scope.rename = ->
      $modal.open
        templateUrl: 'html/rename.html'
        controller: ['$scope', '$modalInstance', 'room', ($scope, $modalInstance, room) ->
          $scope.room = room

          $scope.ok = ->
            $scope.room.$save()
            $scope.room.$promise.then ->
              $modalInstance.close()
        ]
        resolve:
          room: () -> room


    $scope.canLeaveRoom = ->
      me._id != room._acl.creator

    $scope.canDeleteRoom = ->
      me._id == room._acl.creator
]