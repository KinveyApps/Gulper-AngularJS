angular.module 'app.control'

.controller 'app.control.index', [
  '$scope', '$state', '$stateParams', '$facebook', '$kinvey', 'PubNub', 'me', 'users', 'rooms', '$subscriber',
  ($scope, $state, $stateParams, $facebook, $kinvey, PubNub, me, users, rooms, $subscriber) ->

    $scope.me = me
    $scope.users = users
    $scope.rooms = rooms
    $scope.notifications = {}

    leftRoom = (userId, roomId) ->
      console.log userId+' left the room'
      console.log 'i am '+me._id
      if userId == me._id
        console.log 'i left a room'
        rooms.splice getRoomIndex(roomId), 1
        if $state.params._id == roomId
          console.log 'but i\'m still there'
          $state.go 'index.chatter'
      else
        idx = getRoomIndex(roomId)
        newRoom = $kinvey.Room.get
          _id: roomId
        newRoom.$promise.then ->
          rooms[idx] = newRoom

    handleRoomNotification = (event, payload) ->
      $scope.$apply ->
        message = JSON.parse payload.message
        if message.type == 'left-room'
          leftRoom(message.userId, message.roomId)
        else
          if $state.params._id != room._id
            $scope.notifications[room._id]++

    strapRoom = (room) ->
      $scope.notifications[room._id] = 0
      $subscriber.subscribe room._id
      $scope.$on (PubNub.ngMsgEv room._id), handleRoomNotification

    for room in rooms
      do (room) ->
        strapRoom(room)

    PubNub.ngSubscribe
      channel: me._id

    getRoomIndex = (id) ->
      foundRoom = null
      idx = 0
      for room in rooms
        do (room) ->
          if room._id == id
            foundRoom = idx
          idx++
      foundRoom

    $scope.$on (PubNub.ngMsgEv me._id), (event, payload) ->
      if payload.message.type == 'new-room'
        room = $kinvey.Room.get
          _id: payload.message.id
          resolve: 'participants'
          retainReferences: false
        room.$promise.then (room) ->
          strapRoom(room)
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
        $state.go('index.room', {_id: foundRoom._id})
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
      if room.name && room.name.length > 0
        room.name
      else
        count = 0
        name = ''
        for participant in room.participants
          do (participant) ->
            if participant._id != me._id
              if count++ > 0
                name += ', '
              name += participant._socialIdentity.facebook.name
        if name.length == 0
          name = 'So Lonely'
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