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

  .config ['$urlRouterProvider', '$facebookProvider', '$kinveyProvider', 'PubNub',
    ($urlRouterProvider, $facebookProvider, $kinveyProvider, PubNub) ->
      $urlRouterProvider.otherwise '/login'
      $facebookProvider.init
        appId: '229011427294758'
      $kinveyProvider.init
        appKey: 'kid_TTfnnXtg6O'
        appSecret: '3118b76c646343ae94ace92116e9b20c'
        storage: 'local'
      PubNub.init
        publish_key: 'pub-c-54950570-ed66-4f98-8b3b-d101960f63ec'
        subscribe_key: 'sub-c-ea5fd726-be91-11e3-b6e0-02ee2ddab7fe'
    ]
  .run ['$kinvey', ($kinvey) ->
    $kinvey.alias 'room', 'Room'
    $kinvey.alias 'message', 'Message'
  ]