angular.module 'app.control'

.controller 'app.control.index', [
  '$rootScope', '$scope', '$state', '$stateParams', '$facebook', '$kinvey', 'PubNub', 'me', 'users', 'rooms', '$subscriber', '$modal', '$window', '$peer',
  ($rootScope, $scope, $state, $stateParams, $facebook, $kinvey, PubNub, me, users, rooms, $subscriber, $modal, $window, $peer) ->

    $scope.me = me
    $scope.users = users
    $scope.rooms = rooms
    $scope.notifications = {}
    $scope.inCall = false

    $peer.create me._id
    navigator.getMedia = navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia;
    window.URL = window.URL || window.webkitURL || window.mozURL || window.msURL;

    $peer.on 'call', (call) ->
      $scope.$apply ->
        if !$scope.inCall
          calloptions =
            video: true
            audio: true
          navigator.getMedia calloptions, (stream) ->
            call.answer stream
            call.on 'stream', (remoteStream) ->
              $scope.$apply ->
                showCallStream call, remoteStream, stream
            , (err) ->
              console.log err

    $scope.call = (user) ->
      calloptions =
        video: true
        audio: true
      navigator.getMedia calloptions, (stream) ->
        call = $peer.call user._id, stream
        call.on 'stream', ((remoteStream) ->
          $scope.$apply ->
            showCallStream call, remoteStream, stream
        ), ((err) -> console.log err)

    showCallStream = (call, stream, myStream)->
      $scope.inCall = true

      modal = $modal.open
        templateUrl: 'html/call.html'
        controller: ['$scope', 'call', ($scope, call) ->
          call.on 'close', ->
            console.log 'closing event'
            try
              $scope.$close()
          call.on 'error', ->
            console.log 'error event'
            call.close()
            try
              $scope.$close()
        ]
        resolve:
          call: -> call

      modal.opened.then ->
        url = (URL.createObjectURL stream)
        tryShowVideo = ->
          setTimeout ->
            if $('#call').length > 0
              $('#call').prop 'src', url
            else
              tryShowVideo()
          , 10
        tryShowVideo()

        url1 = (URL.createObjectURL myStream)
        tryShowVideo1 = ->
          setTimeout ->
            if $('#call1').length > 0
              $('#call1').prop 'src', url1
            else
              tryShowVideo1()
          , 10
        tryShowVideo1()


      modal.result.then ->
        call.close()
      , ->
        call.close()


    $window.setKeyOnUserAndSave = (key, value, cb, eb) ->
      me[key] = value
      me.$save().then cb, eb

    leftRoom = (userId, roomId) ->
      if userId == me._id
        rooms.splice getRoomIndex(roomId), 1
        if $state.params._id == roomId
          $state.go 'index.chatter'
      else
        idx = getRoomIndex(roomId)
        rooms[idx].$get
          resolve: 'participants'
          retainReferences: false

    handleRoomNotification = (event, payload, room) ->
      $scope.$apply ->
        message = JSON.parse payload.message
        if message.type == 'left-room'
          leftRoom(message.userId, message.roomId)
        else if message.type == 'room-renamed'
          room.name = message.name
        else if message.type == 'room-deleted'
          rooms.splice getRoomIndex(room._id), 1
          if $state.params._id == room._id
            ($modal.open
              templateUrl: 'html/deleted.html')
            .result.then ->
              $state.go 'index.chatter'
        else if message.type == 'join-room'
          roomId = message.roomId
          idx = getRoomIndex(roomId)
          if idx == -1
            $kinvey.Room.get
              _get: roomId
            .$promise.then (room) ->
              strapRoom room
              rooms.push room
          else
            console.log 'really? You are lying.'
            rooms[idx].$get
              resolve: 'participants'
              retainReferences: false
        else
          console.log 'got a notification'
          $rootScope.$broadcast 'chatter-notification', message
          if $state.params._id != room._id
            $scope.notifications[room._id]++


    strapRoom = (room) ->
      $scope.notifications[room._id] = 0
      $subscriber.subscribe room._id
      $scope.$on (PubNub.ngMsgEv room._id), (event, payload) -> handleRoomNotification event, payload, room

    for room in rooms
      do (room) ->
        strapRoom(room)

    PubNub.ngSubscribe
      channel: me._id

    PubNub.ngSubscribe
      channel: 'online'

    $scope.userStati = {}

    setOnlineStatus = (uuid, status)->
      foundUser = null
      for user in $scope.users
        console.log user._id, uuid
        if user._id == uuid
          foundUser = user;
          break;

      if foundUser?
        $scope.$apply ->
          $scope.userStati[foundUser._id] = status
          console.log 'Set user status: ', status, uuid
      else
        console.log 'Unable to find user with ID to set status on', uuid


    $scope.$on PubNub.ngPrsEv('online'), (event, payload)->
      if payload.event.service == 'Presence'
        for users in payload.event.uuids
          setOnlineStatus(users.uuid, true)

    PubNub.ngHereNow {channel: 'online'}

    $scope.$on PubNub.ngPrsEv('online'), (event, payload)->
      if payload.channel == 'online'
        if payload.event.action == 'leave' || payload.event.action == 'timeout'
          setOnlineStatus(payload.event.uuid, false)
        else if payload.event.action == 'join'
          setOnlineStatus(payload.event.uuid, true)


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

      console.log 'Creating room?', foundRoom
      if foundRoom
        $state.go('index.room', {_id: foundRoom._id})
      else
        console.log 'Creating new room.'
        room = new $kinvey.Room
          _acl:
            r: [user._id, me._id]
            w: [user._id, me._id]
          participants: [me, user]
        room.$save().then (room) ->
          console.log 'Room Saved', room
          room.participants = [me, user]
          $scope.rooms.push room
          console.log room._id
          $state.go('index.room', {_id: room._id})
        , (err)->
          console.log 'error creating room!', err

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
              name += $scope.userName(participant)
        if name.length == 0
          name = 'So Lonely'
        name

    $scope.isActive = (room) ->
      $state.params._id == room._id

    $scope.chatterIsActive = ->
      $state.current.name == 'index.chatter'

    $scope.userPicture = (user) ->
      if user._socialIdentity.facebook
        picture = 'http://graph.facebook.com/'+user._socialIdentity.facebook.id+'/picture'
        picture
      else if user._socialIdentity.google
        user.picture

    $scope.userName = (user) ->
      if user._type == 'KinveyRef'
        return 'KinveyRef'

      if user._socialIdentity.facebook
        user._socialIdentity.facebook.name
      else if user._socialIdentity.google
        user._socialIdentity.google.given_name + ' ' + user._socialIdentity.google.family_name
      else
        user.username
]