angular.module 'app', [
  'app.control',
  'app.state',
  'app.templates',
  'app.service',
  'ui.router',
  'facebook',
  'kinvey',
  'ngStorage',
  'angularMoment'
]

  .config ['$urlRouterProvider', '$facebookProvider', '$kinveyProvider',
    ($urlRouterProvider, $facebookProvider, $kinveyProvider) ->
      $urlRouterProvider.otherwise '/login'
      $facebookProvider.init
        appId: '229011427294758'
      $kinveyProvider.init
        appKey: 'kid_TTfnnXtg6O'
        appSecret: '3118b76c646343ae94ace92116e9b20c'
        storage: 'local'
    ]
  .run ['$kinvey', ($kinvey) ->
    $kinvey.alias 'room', 'Room'
    $kinvey.alias 'message', 'Message'
  ]