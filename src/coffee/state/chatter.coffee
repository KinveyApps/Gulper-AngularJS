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

    me: ['$kinvey', '$state', '$q', ($kinvey, $state, $q) ->
      deferred = $q.defer()
      $kinvey.User.current().$promise.then ((response) ->
        deferred.resolve response
      ), ((error)->
        console.log error
        $state.go 'login'
      )
      return deferred.promise
    ]

    messages: ['$kinvey', 'me', ($kinvey, me) ->
      $kinvey.Message.query
        query:
          from:
            $ne: me.$reference()
          _id:
            $exists: true
        resolve: 'from'
        retainReferences: false
    ]
}