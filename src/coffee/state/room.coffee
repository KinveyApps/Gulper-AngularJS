angular.module 'app.state'

.constant 'app.state.room', {
  name: 'index.room',
  url: '/room/:_id',
  templateUrl: 'html/room.html',
  controller: 'app.control.room',
  resolve:

    room: ['$kinvey', '$stateParams', ($kinvey, $stateParams) ->
      $kinvey.Room.get $stateParams
    ]
}