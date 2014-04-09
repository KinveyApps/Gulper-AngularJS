angular.module 'app.control'

.controller 'app.control.room', [
  '$scope', '$state', '$stateParams', '$kinvey', 'PubNub', 'room', 'messages', 'me', '$subscriber', '$modal', 'admin',
  ($scope, $state, $stateParams, $kinvey, PubNub, room, messages, me, $subscriber, $modal, admin) ->

    $scope.room = room
    $scope.admin = admin
    $scope.messages = messages

    $scope.$parent.notifications[room._id] = 0
    $subscriber.subscribe room._id

    $scope.$on (PubNub.ngMsgEv room._id), (event, payload) ->
      $scope.$apply ->
        payload.message = JSON.parse payload.message
        if !payload.message.type
          message = new $kinvey.Message payload.message
          $scope.messages.push message
        else if payload.message.type == 'join-room'
          room.$get
            resolve: 'participants'
            retainReferences: false

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

    $scope.addUser = ->
      ($modal.open
        templateUrl: 'html/addUser.html'
        controller: ['$scope', '$modalInstance', 'users', ($scope, $modalInstance, users) ->
          $scope.users = users
        ]
        scope: $scope
        resolve:
          users: ['$kinvey', ($kinvey) ->
            participantIds = []
            for participant in room.participants
              do (participant) ->
                participantIds.push participant._id
            console.log participantIds
            $kinvey.User.query
              query:
                _id:
                  $nin: participantIds
          ]
      ).result.then (user) ->
        $kinvey.rpc 'addUserToRoom',
          user: user.$reference()
          room: room.$reference()

    $scope.canLeaveRoom = ->
      me._id != room._acl.creator

    $scope.canDeleteRoom = ->
      me._id == room._acl.creator
]