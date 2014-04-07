angular.module 'app.state', ['ui.router']
  .config ['$stateProvider', '$injector',
           ($stateProvider, $injector) ->

             angular.forEach [
               'app.state.login'
               'app.state.index'
               'app.state.room'
             ], (stateName) ->

               state = $injector.get(stateName)
               $stateProvider.state(state.name, state)
   ]