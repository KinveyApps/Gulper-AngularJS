angular.module 'app.control'

.controller 'app.control.chatter', [
  '$scope', '$state', '$stateParams', '$kinvey', 'PubNub', 'rooms', 'messages', 'me', '$subscriber',
  ($scope, $state, $stateParams, $kinvey, PubNub, rooms, messages, me, $subscriber) ->

    $scope.rooms = rooms
    $scope.messages = messages

    $scope.$on 'chatter-notification', (event, payload) ->
      if payload.text
        message = new $kinvey.Message payload
        $scope.messages.push message
        setTimeout ->
          $('.chat-pane').animate({ scrollTop: $('.chat-pane')[0].scrollHeight }, 250)
        , 0

    setTimeout ->
      $('.chat-pane').animate({ scrollTop: $('.chat-pane')[0].scrollHeight }, 250)
    , 300
]