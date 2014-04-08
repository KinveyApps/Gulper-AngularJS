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
  'pubnub.angular.service'
]

  .config ['$urlRouterProvider', '$facebookProvider', '$kinveyProvider', '$httpProvider',
    ($urlRouterProvider, $facebookProvider, $kinveyProvider, $httpProvider) ->
      $urlRouterProvider.otherwise '/login'
      $facebookProvider.init
        appId: '229011427294758'
      $kinveyProvider.init
        appKey: 'kid_eeM4Dtly69'
        appSecret: 'f7b5cd34caa047c286e6a3ba09204117'
        storage: 'local'
      $httpProvider.interceptors.push 'v3yk1n-interceptor'
    ]
  .run ['$kinvey', ($kinvey) ->
    $kinvey.alias 'room', 'Room'
    $kinvey.alias 'message', 'Message'
  ]