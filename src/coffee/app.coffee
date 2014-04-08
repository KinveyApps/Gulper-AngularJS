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
  .run ['$kinvey', 'PubNub', ($kinvey, PubNub) ->
    $kinvey.alias 'room', 'Room'
    $kinvey.alias 'message', 'Message'
    PubNub.init
      publish_key: 'pub-c-54950570-ed66-4f98-8b3b-d101960f63ec'
      subscribe_key: 'sub-c-ea5fd726-be91-11e3-b6e0-02ee2ddab7fe'
  ]