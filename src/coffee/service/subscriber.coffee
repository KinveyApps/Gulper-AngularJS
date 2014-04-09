angular
  .module 'app.service'
  .service '$subscriber', ['PubNub', (PubNub)->
    subscriptions = []
    api =
      subscribe: (channel) ->
        if (subscriptions.indexOf channel) == -1
          PubNub.ngSubscribe
            channel: channel
    api
  ]