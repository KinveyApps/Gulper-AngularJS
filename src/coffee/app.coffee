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
  'pubnub.angular.service',
  'googleplus'
]

  .config ['$urlRouterProvider', '$facebookProvider', '$kinveyProvider', '$httpProvider', 'GooglePlusProvider',
    ($urlRouterProvider, $facebookProvider, $kinveyProvider, $httpProvider, GooglePlusProvider) ->
      $urlRouterProvider.otherwise '/login'
      $facebookProvider.init
        appId: '229011427294758'
      GooglePlusProvider.init
        clientId: '1069600990715-qr2quvqt0nl1nr8vkdtljtu0jnb22igv.apps.googleusercontent.com'
        apiKey: 'AIzaSyCmqKjIhh5ySTPDprOkfKHkKdPq6_FFR1Y'
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