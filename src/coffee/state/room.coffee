angular.module 'app.state'

.constant 'app.state.room', {
  name: 'index.room',
  url: '/room/:_id',
  templateUrl: 'html/room.html',
  controller: 'app.control.room',
  resolve:

    room: ['$kinvey', '$stateParams', ($kinvey, $stateParams) ->
      $kinvey.Room.get $stateParams
        .$promise
    ]

    messages: ['$kinvey', '$stateParams', 'room', ($kinvey, $stateParams, room) ->
      $kinvey.Message.query
        query:
          room: room.$reference()
        resolve: 'from'
        retainReferences: false
    ]
}