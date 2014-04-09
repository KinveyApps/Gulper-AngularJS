angular
  .module 'app.service'
  .provider '$peer', [ ->

    my =
      peer: null
    key = null
    init = (apiKey) ->
      key = apiKey

    $get = ->
      create: (id) ->
        if null == my.peer
          my.peer = new Peer id, key: key

      on: (event, cb, eb) ->
        my.peer.on event, cb, eb

      call: (id, stream) ->
        my.peer.call id, stream

    api =
      init: init
      $get: $get
    api
]