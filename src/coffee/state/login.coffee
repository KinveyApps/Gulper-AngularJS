angular.module 'app.state'

.constant 'app.state.login', {
  name: 'login',
  url: '/login',
  templateUrl: 'html/login.html',
  controller: 'app.control.login',
  resolve:
    me: ['$kinvey', '$state', '$q', ($kinvey, $state, $q) ->
      deferred = $q.defer()
      $kinvey.User.current().$promise.then (->
        $state.go 'index.chatter'
      ), (->
        deferred.resolve null
      )
      return deferred.promise
    ]
}