angular.module 'app.control'

.controller 'app.control.index', [
  '$scope', '$state', '$stateParams', '$facebook', '$kinvey', 'PubNub', 'me', 'users', 'rooms',
  ($scope, $state, $stateParams, $facebook, $kinvey, PubNub, me, users, rooms) ->

    $scope.me = me
    $scope.users = users
    $scope.rooms = rooms

    PubNub.ngSubscribe
      channel: me._id

    $scope.$on (PubNub.ngMsgEv me._id), (event, payload) ->
      room = new $kinvey.Room payload
      $scope.rooms.push room

    $scope.logout = ->
        $kinvey.User.logout().$promise.then ->
          $state.go 'login'

    $scope.openRoom = (user) ->

      # find a suitable room that exists if possible, if not make a new room and open that
      # a room is suitable if it has only the target user and me
      foundRoom = null
      for room in rooms
        do (room) ->
          userId = false
          myId = false
          if room.participants.length == 2
            for participant in room.participants
              do (participant) ->
                myId = myId || (participant._id == me._id)
                userId = userId || (participant._id == user._id)
          if userId && myId
            foundRoom = room

      if foundRoom
        $state.go('.room', {_id: foundRoom._id})
      else
        room = new $kinvey.Room
          _acl:
            r: [user._id, me._id]
            w: [user._id, me._id]
          participants: [me, user]
        room.$save().then (room) ->
          room.participants = [me, user]
          $scope.rooms.push room

    $scope.roomName = (room) ->
      count = 0
      name = ''
      for participant in room.participants
        do (participant) ->
          if participant._id != me._id
            if count++ > 0
              name += ', '
            name += participant._socialIdentity.facebook.name
      name

    $scope.isActive = (room) ->
      $state.params._id == room._id

    $scope.chatterIsActive = ->
      $state.current.name == 'index.chatter'

    $scope.userName = (user) ->
      if user._socialIdentity.facebook
        user._socialIdentity.facebook.name
      else if user._socialIdentity.google
        user._socialIdentity.google.given_name + ' ' + user._socialIdentity.google.family_name
      else
        user.username
]