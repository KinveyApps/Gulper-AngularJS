angular.module 'app.state'

.constant 'app.state.chatter', {
  name: 'index.chatter',
  url: '/chatter',
  templateUrl: 'html/chatter.html',
  controller: 'app.control.chatter',
  resolve:

    rooms: ['$kinvey', ($kinvey) ->
      $kinvey.Room.query
        query:
          _id:
            $exists: true
        resolve: 'participants'
        retainReferences: false
    ]

    messages: ['$kinvey', '$stateParams', 'rooms', ($kinvey, $stateParams, rooms) ->
      $kinvey.Message.query
        query:
          _id:
            $exists: true
        resolve: 'from'
        retainReferences: false
    ]
}