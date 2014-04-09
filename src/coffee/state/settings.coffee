angular.module 'app.state'

.constant 'app.state.settings', {
  name: 'settings',
  url: '/settings',
  templateUrl: 'html/settings.html',
  controller: 'app.control.settings',
  resolve:

    me: ['$kinvey', ($kinvey) ->
      $kinvey.User.current().$promise
    ]
}