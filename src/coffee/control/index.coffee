angular.module 'app.control'

.controller 'app.control.index', [
  '$scope', '$state', '$facebook', '$kinvey', 'me', 'users', 'rooms',
  ($scope, $state, $facebook, $kinvey, me, users, rooms) ->

    $scope.me = me
    $scope.users = users
    $scope.rooms = rooms

    $scope.logout = ->
      $facebook.logout().then ->
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
        foundRoom
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
]