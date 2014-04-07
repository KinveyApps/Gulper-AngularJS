describe 'app', ->
  describe 'state', ->
    describe 'module', ->

      $ = {}

      beforeEach ->
        module 'app.state'
        inject ($injector) ->
          $.injector = $injector
          $.state = $.injector.get '$state'

      angular.forEach [
        'app.state.login'
      ], (stateName) ->
        it 'should set up '+stateName, ->

          state = $.injector.get stateName
          expect $.state.get state.name
            .toBe state