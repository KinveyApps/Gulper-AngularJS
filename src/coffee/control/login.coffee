angular.module 'app.control'

.controller 'app.control.login',
  ['$scope', '$kinvey', '$facebook', '$moment', '$state', 'PubNub',
    ($scope, $kinvey, $facebook, $moment, $state, PubNub) ->

      loginSuccess = (user) ->
        PubNub.uuid (uuid)->
          console.log(uuid)
          return uuid
        $state.go 'index'

      loginFailure = (error) ->
        console.log error

      kinveyAuth = (fbResponse) ->
        user = new $kinvey.User
          _id: ''
          _socialIdentity:
            facebook:
              access_token: fbResponse.authResponse.accessToken
              expires: ''+($moment().second() + fbResponse.authResponse.expiresIn)
        user.$login().then loginSuccess, ->
          user.$signup().then loginSuccess, loginFailure

      $scope.login = ->
        $facebook.login()
        .then kinveyAuth, loginFailure

  ]