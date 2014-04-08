angular
  .module 'app.service'
  .factory 'v3yk1n-interceptor', ->
    interceptor =
      request: (config) ->
        config.url = config.url.replace 'https://baas.kinvey.com', 'https://v3yk1n.kinvey.com'
        config
    interceptor