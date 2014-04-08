angular.module 'app.control'

.controller 'app.control.login',
  ['$scope', '$kinvey', '$facebook', '$moment', '$state', 'PubNub', 'GooglePlus',
    ($scope, $kinvey, $facebook, $moment, $state, PubNub, GooglePlus) ->

      loginSuccess = ->
        $state.go 'index.chatter'

      loginFailure = (error) ->
        console.log error

      kinveyFbAuth = (fbResponse) ->
        user = new $kinvey.User
          _id: ''
          _socialIdentity:
            facebook:
              access_token: fbResponse.authResponse.accessToken
              expires: ''+($moment().second() + fbResponse.authResponse.expiresIn)
        user.$login().then loginSuccess, ->
          user.$signup().then loginSuccess, loginFailure

      kinveyGpAuth = (gpResponse) ->
        user = new $kinvey.User
          _id: ''
          _socialIdentity:
            google:
              access_token: gpResponse.access_token
              expires_in: gpResponse.access_token
        console.log user
        user.$login().then loginSuccess, ->
          user.$signup().then loginSuccess, loginFailure

      $scope.fbLogin = ->
        $facebook.fbLogin()
          .then kinveyFbAuth, loginFailure

      $scope.gpLogin = ->
        GooglePlus.login()
          .then kinveyGpAuth, loginFailure

  ]