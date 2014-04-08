angular.module 'app.state'

.constant 'app.state.index', {
  name: 'index',
  url: '',
  templateUrl: 'html/index.html',
  controller: 'app.control.index',
  abstract: true
  resolve:

    me: ['$kinvey', '$state', '$q', 'PubNub', ($kinvey, $state, $q, PubNub) ->
      deferred = $q.defer()
      $kinvey.User.current().$promise.then ((response) ->
        PubNub.init
          publish_key: 'pub-c-54950570-ed66-4f98-8b3b-d101960f63ec'
          subscribe_key: 'sub-c-ea5fd726-be91-11e3-b6e0-02ee2ddab7fe'
          uuid: response._id
        deferred.resolve response
      ), ((error)->
        console.log error
        $state.go 'login'
      )
      return deferred.promise
    ]

    users: ['$kinvey', 'me', ($kinvey, me) ->
      $kinvey.User.query
        query:
          _id:
            $ne: me._id
    ]

    rooms: ['$kinvey', ($kinvey) ->
      $kinvey.Room.query
        query:
          _id:
            $exists: true
        resolve: 'participants'
        retainReferences: false
    ]
}