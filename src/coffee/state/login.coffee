angular.module 'app.state'

.constant 'app.state.login', {
  name: 'login',
  url: '/login',
  templateUrl: 'html/login.html',
  controller: 'app.control.login'
}