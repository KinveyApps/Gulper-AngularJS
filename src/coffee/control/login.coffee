angular.module 'app.control'

  .controller 'app.control.login',
    ['$scope', '$kinvey', '$facebook', '$moment',
      ($scope, $kinvey, $facebook, $moment) ->


        $scope.login = ->
          $facebook.login()
            .then ((response) ->
              console.log response
              credentials =
                _socialIdentity:
                  facebook:
                    access_token: response.authResponse.accessToken
                    expires: ''+($moment().millisecond() + response.authResponse.expiresIn)
              $kinvey.User.login credentials
                .$promise.then ((response) ->
                  console.log response
                ), ((error) ->
                  console.log error
                )
            ), ((error) ->
              console.log error
            )

      ]