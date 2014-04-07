angular.module 'app.state'

.constant 'app.state.index', {
  name: 'index',
  url: '/',
  templateUrl: 'html/index.html',
  controller: 'app.control.index',
  resolve:
    me: ['$kinvey', '$state', '$q', ($kinvey, $state, $q) ->
      deferred = $q.defer()
      $kinvey.User.current().$promise.then ((response) ->
        console.log response
        deferred.resolve response
      ), ( (error)->
        console.log error
        $state.go 'login'
      )
      return deferred.promise
    ]
}