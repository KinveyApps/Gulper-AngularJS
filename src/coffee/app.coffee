angular.module 'app', [
  'app.control',
  'app.state',
  'app.templates',
  'app.service',
  'ui.router',
  'facebook',
  'kinvey'
]

  .config ['$urlRouterProvider', '$facebookProvider',
    ($urlRouterProvider, $facebookProvider) ->
      $urlRouterProvider.otherwise '/login'
      $facebookProvider.init
        appId: '229011427294758'
    ]