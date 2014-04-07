angular.module 'app.state', ['ui.router']
  .config ['$stateProvider', '$injector',
           ($stateProvider, $injector) ->

             angular.forEach [
               'app.state.login'
             ], (stateName) ->

               state = $injector.get(stateName)
               $stateProvider.state(state.name, state)
   ]